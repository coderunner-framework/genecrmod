
class CodeRunner
  #  This is a customised subclass of the CodeRunner::Run  class which allows CodeRunner to run and analyse the GENE gyrokinetic code (see http://www2.ipp.mpg.de/~fsj/gene/)
  #
  #p 'hellllllooooo!!!'
  class Gene < Run::FortranNamelist
    #include CodeRunner::SYSTEM_MODULE
    #




    # Where this file is
    @code_module_folder =  File.dirname(File.expand_path(__FILE__)) # i.e. the directory this file is in

    # Use the Run::FortranNamelist tools to process the variable database
    setup_namelists(@code_module_folder)

    # Setup gs2 in case people are using it

    ################################################
    # Quantities that are read or determined by CodeRunner
    # after the simulation has ended
    ###################################################

    @results = [
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
      #p ['id', id, 'ctd', ctd]
      #p rcp.results.zip(rcp.results.map{|r| send(r)})
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



    # Modify new_run so that it becomes a restart of self. Adusts
    # all the parameters of the new run to be equal to the parameters
    # of the run that calls this function, and sets up its run name
    # correctly
    def restart(new_run)
      raise "Restart not tested yet"
      #new_run = self.dup
      (rcp.variables).each{|v| new_run.set(v, send(v)) if send(v)}
      #if @flux_option == "gs2"
        #gs2_runs.each_with_index do |run, i|
          #CodeRunner::Gs2.rcp.variables.each{|v| new_run.gs2_runs[i].set(v, run.send(v)) if run.send(v)}
        #end
      #end
      #@naming_pars.delete(:preamble)
      #SUBMIT_OPTIONS.each{|v| new_run.set(v, self.send(v)) unless new_run.send(v)}
      ##(rcp.results + rcp.gs2_run_info).each{|result| new_run.set(result, nil)}
      new_run.is_a_restart = true
      new_run.restart_id = @id
      new_run.restart_run_name = @run_name
      new_run.nopt = -1
      #new_run.init_option = "restart"
      #new_run.iternt_file = @run_name + ".iternt"
      #new_run.iterflx_file = @run_name + ".iterflx"
      #new_run.init_file = @run_name + ".tmp"
      #@runner.nprocs = @nprocs if @runner.nprocs == "1" # 1 is the default so this means the user probably didn't specify nprocs
      #raise "Restart must be on the same number of processors as the previous run: new is #{new_run.nprocs.inspect} and old is #{@nprocs.inspect}" if !new_run.nprocs or new_run.nprocs != @nprocs
    ###   @runner.parameters.each{|var, value| new_run.set(var,value)} if @runner.parameters
    ###   ep @runner.parameters
      new_run.run_name = nil
      new_run.naming_pars = @naming_pars
      new_run.update_submission_parameters(new_run.parameter_hash.inspect, false) if new_run.parameter_hash
      new_run.naming_pars.delete(:restart_id)
      new_run.generate_run_name
      #new_run.run_name += '_t'
      eputs 'Copying GENE Restart file'
      ##system "ls #@directory"
      FileUtils.cp("#@directory/NOUT", "#{new_run.directory}/NIN")
      ##########if new_run.flux_option == "gs2" and @flux_option == "gs2"
        ##########for i in 0...n_flux_tubes
          ##########new_run.gs2_runs[i].directory = new_run.directory + "/flux_tube_#{i+1}"
          ##########FileUtils.makedirs(new_run.gs2_runs[i].directory)
          ###########ep ['gs2_runs[i] before', gs2_runs[i].nwrite, new_run.gs2_runs[i].nwrite, new_run.gs2_runs[i].parameter_hash]
          ##########gs2_runs[i].restart(new_run.gs2_runs[i])
          ###########ep ['gs2_runs[i] after', gs2_runs[i].nwrite, new_run.gs2_runs[i].nwrite, new_run.gs2_runs[i].parameter_hash]
          ###########new_run.gs2_runs[i].run_name = new_run.run_name + (i+1).to_s
        ##########end
      ##########end
      ##@runner.submit(new_run)
      #new_run
    end
    #  This is a hook which gets called just before submitting a simulation. It sets up the folder and generates any necessary input files.
    def generate_input_file
        check_parameters
        if @restart_id
          @runner.run_list[@restart_id].restart(self)
        end
        @diagdir = "."
        @n_procs_sim = actual_number_of_processors
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
      #text << "&#{namelist}#{ext}\n"
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

    def check_parameters
    end



  def vim_output
    system "vim -Ro #{output_file} #{error_file}"
  end
  alias :vo :vim_output

    #  This command uses the infrastructure provided by Run::FortranNamelist, provided by CodeRunner itself.
    def write_input_file
      #File.open("#@run_name.in", 'w'){|file| file.puts input_file_text}
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
      #p ['id is', id, 'ctd is ', ctd]
      #if ctd
        #get_global_results
      #end
      #p ['fusionQ is ', fusionQ]
      @percent_complete = completed_timesteps.to_f / ntimesteps.to_f * 100.0
    end

    def get_status
			if @running
				get_completed_timesteps
				if completed_timesteps == 0
					@status = :NotStarted
				else
					@status = :Incomplete
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
        @completed_timesteps = %x[grep '^\\s\\+\\S\\+\\s*$' nrg.dat].split("\n").size
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

@msdatching_regex = Regexp.new('(^|\A)(?<everything>[^!
]*?\b #a word boundary

  (?<name>[A-Za-z_]\w*)  # the name, which must be a single word (not beginning
          # with a digit) followed by

  \s*=\s*    # an equals sign (possibly with whitespace either side), then

  (?<default>(?>    # the default answer, which can be either:

    (?<string>' + Regexp.quoted_string.to_s + ')      # a quoted string

    |           # or


                (?<float>\-?(?:(?>\d+\.\d*)|(?>\d*\.\d+))(?:[eEdD][+-]?\d+)?)(?:_RKIND)? # a floating point number

    |           #or

    (?<int>\-?\d++) # an integer

    |         #or

                (?<complex>\((?:\-?(?:(?>\d+\.\d*)|(?>\d*\.\d+))(?:[eEdD][+-]?\d+)?),\s*(?:\-?(?:(?>\d+\.\d*)|(?>\d*\.\d+))(?:[eEdD][+-]?\d+)?)\)) #a complex number

    |         #or


    (?:(?<word>\S+)(?=\s|\)|\]|[\n\r]+|\Z)) # a single word containing no spaces
            # which must be followed by a space or ) or ] or \n or \Z

  )))', Regexp::EXTENDED)
  end
end

