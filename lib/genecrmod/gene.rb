
class CodeRunner
  #  This is a customised subclass of the CodeRunner::Run  class which allows CodeRunner to run and analyse the GENE gyrokinetic code (see http://www2.ipp.mpg.de/~fsj/gene/)
  #
  class Gene < Run::FortranNamelist
    #include CodeRunner::SYSTEM_MODULE
    # Where this file is
    @code_module_folder =  File.dirname(File.expand_path(__FILE__)) # i.e. the directory this file is in

    require @code_module_folder + '/hdf5.rb'
    require @code_module_folder + '/check_parameters.rb'

    # Use the Run::FortranNamelist tools to process the variable database
    setup_namelists(@code_module_folder)

    ################################################
    # Quantities that are read or determined by CodeRunner
    # after the simulation has ended
    ###################################################

    @results = [
			:growth_rates
    ]

    @code_long="GENE Gyrokinetic Electromagnetic Numerical Experiment"

    @run_info=[:time, :is_a_restart, :restart_id, :restart_run_name, :completed_timesteps, :percent_complete]

    @uses_mpi = true

    @modlet_required = false

    @naming_pars = []

    #  Any folders which are a number will contain the results from flux simulations.
    @excluded_sub_folders = []

    #  A hook which gets called when printing the standard run information to the screen using the status command.
    def print_out_line
      name = @run_name
      name += " (res: #@restart_id)" if @restart_id
      name += " real_id: #@real_id" if @real_id
      beginning = sprintf("%2d:%d %-60s %1s:%2.1f(%s) %3s%1s",  @id, @job_no, name, @status.to_s[0,1],  @run_time.to_f / 60.0, @nprocs.to_s, percent_complete, "%")
      if ctd
        #beginning += sprintf("Q:%f, Pfusion:%f MW, Ti0:%f keV, Te0:%f keV, n0:%f x10^20", fusionQ, pfus, ti0, te0, ne0)
      end
      beginning += "  ---#{@comment}" if @comment
      beginning
    end



    # Modify new_run so that it becomes a restart of self. Adjusts
    # all the parameters of the new run to be equal to the parameters
    # of the run that calls this function, and sets up its run name
    # correctly
    def restart(new_run)
      (rcp.variables).each{|v| new_run.set(v, send(v)) if send(v)}
      new_run.is_a_restart = true
      new_run.restart_id = @id
      new_run.restart_run_name = @run_name
      new_run.run_name = nil
      new_run.naming_pars = @naming_pars
      new_run.update_submission_parameters(new_run.parameter_hash.inspect, false) if new_run.parameter_hash
      new_run.naming_pars.delete(:restart_id)
      new_run.generate_run_name

      eputs 'Copying GENE restart file'
      if (@chpt_h5 and @chpt_h5.fortran_true?)
        new_run.chpt_read_h5 = ".true."
        FileUtils.cp("#@directory/checkpoint.h5", "#{new_run.directory}/checkpoint.h5")
      else
        new_run.read_checkpoint = ".true."
        FileUtils.cp("#@directory/checkpoint", "#{new_run.directory}/checkpoint")
      end
    end

    #  This is a hook which gets called just before submitting a simulation. It sets up the folder and generates any necessary input files.
    def generate_input_file
        check_parameters
        if @restart_id
          @runner.run_list[@restart_id].restart(self)
        end
        @diagdir = "."
        @n_procs_sim = actual_number_of_processors
        # Simulation time limit is set to ~ 90% of wall mins to allow GENE to 
        # exit gracefully
        @timelim = @wall_mins * 55 if @wall_mins
        write_input_file
    end

    def self.parse_input_file(input_file, strict=true)
      if FileTest.file? input_file
        text = File.read(input_file)
      else
        text = input_file
      end
      i = 0
      text.gsub!(/^(&species)/i){p $~; "#{$1}_#{i+=1}"}
      super(text)
    end
    def namelist_text(namelist, enum = nil)
      hash = rcp.namelists[namelist]
      text = ""
      ext = enum ? "_#{enum}" : ""
      text << "!#{'='*30}\n!#{hash[:description]} #{enum} \n!#{'='*30}\n" if hash[:description]
      text << "&#{namelist}\n"
      hash[:variables].each do |var, var_hash|
        code_var = (var_hash[:code_name] or var)
        cr_var = var+ext.to_sym
        value = send(cr_var)
        if send(cr_var) and (not var_hash[:should_include] or  eval(var_hash[:should_include]))
          if value.kind_of? Array
            value.each_with_index do |v, i|
              output = formatted_variable_output(v)
              text << " #{code_var}(#{i+1}) = #{output} #{var_hash[:description] ? "! #{var_hash[:description]}": ""}\n"
            end
          else
            output = formatted_variable_output(value)
            text << " #{code_var} = #{output} #{var_hash[:description] ? "! #{var_hash[:description]}": ""}\n"
          end
        elsif rcp.namelists_to_print_not_specified? and rcp.namelists_to_print_not_specified.include?(namelist)
          text << "  ! #{code_var} not specified --- #{var_hash[:description]}\n"
        end
      end
      text << "/\n\n"
      text
    end




  def vim_output
    system "vim -Ro #{output_file} #{error_file}"
  end
  alias :vo :vim_output

    #  This command uses the infrastructure provided by Run::FortranNamelist, provided by CodeRunner itself.
    def write_input_file
      File.open("parameters", 'w'){|file| file.puts input_file_text}
    end

    # Parameters which follow the Trinity executable, in this case just the input file.
    def parameter_string
      ""
    end

    def parameter_transition
    end

    def generate_component_runs
      #puts "HERE"
    end



    @source_code_subfolders = []

    # This method, as its name suggests, is called whenever CodeRunner is asked to analyse a run directory. This happens if the run status is not :Complete, or if the user has specified recalc_all(-A on the command line) or reprocess_all (-a on the command line).
    #
    def process_directory_code_specific
      get_status
      if ctd
        #get_global_results
        if !nonlinear or nonlinear.fortran_false?
          get_growth_rates
        end
      end
      @percent_complete = completed_timesteps.to_f  * (istep_nrg||10) / ntimesteps.to_f * 100.0
    end

    def get_status
			if @running
        if @status != :Queueing
          get_completed_timesteps
          if completed_timesteps == 0
            @status = :NotStarted
          else
            @status = :Incomplete
          end
        end
			else
				get_completed_timesteps
				if @completed_timesteps == @ntimesteps
					@status = :Complete
				else
					if FileTest.exist?('GENE.finished')
						@status = :Complete
					else
						@status = :Failed
					end
				end
			end
    end
		def get_completed_timesteps
			Dir.chdir(@directory) do
          @completed_timesteps = %x[grep '^\\s\\+\\S\\+\\s*$' nrg.dat 2>/dev/null].split("\n").size
			end
		end


    @fortran_namelist_source_file_match = /((\.F9[05])|(\.fpp)|COMDAT.inc)$/
    @fortran_namelist_source_file_match = /((\.F9[05]))$/

    def input_file_header
      <<EOF
!==============================================================================
!     GENE input file automatically generated by CodeRunner
!==============================================================================
!
!  GENE is a code for solving the nonlinear gyrokinetic equation.
!
!    See http://www2.ipp.mpg.de/~fsj/gene/
!
!  CodeRunner is a framework for the automated running and analysis
!  of large simulations.
!
!   See http://coderunner.sourceforge.net
!
!  Created #{Time.now.to_s}
!      by CodeRunner version #{CodeRunner::CODE_RUNNER_VERSION.to_s}
!
!==============================================================================

EOF
    end
    def self.defaults_file_header
      <<EOF1
############################################################################
#                                                                          #
# Automatically generated defaults file for the GENE CodeRunner module     #
#                                                                          #
# This defaults file specifies a set of defaults for GENE which are        #
# used by CodeRunner to set up and run GENE simulations.                   #
#                                                                          #
############################################################################

# Created: #{Time.now.to_s}

@defaults_file_description = ""
EOF1
    end


    def input_file_extension
      ''
    end

    def get_growth_rates
      Dir.chdir(@directory) do
        if FileTest.exist?(ofile = 'omega.dat.h5')
          @kyvals = get_h5_narray_all(ofile, '/ky').to_gslv
          @growth_rates = get_h5_narray_all(ofile, '/gamma').to_gslv
          @frequencies = get_h5_narray_all(ofile, '/omega').to_gslv
        elsif FileTest.exist?('omega.dat')
          @kyvals, @growth_rates, @frequencies = GSL::Vector.filescan('omega.dat')
        else
          @kyvals, @growth_rates, @frequencies = [nil] * 3
        end
      end
    end
    # This is a temporary hack... we should do this properly!!!
    def graphkit(name, options={})
      case name
      when /growth_rates_vs_ky/
        return GraphKit.quick_create([@kyvals, @growth_rates])
      when /ion_n2_vs_time/
        return GraphKit.quick_create([get_h5_narray_all('nrg.dat.h5', '/nrgIons/time').to_gslv, get_h5_narray_all('nrg.dat.h5', '/nrgIons/n2').to_gslv])

      end
    end

  end
end

