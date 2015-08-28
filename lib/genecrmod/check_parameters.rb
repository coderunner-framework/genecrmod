
class CodeRunner::Gene
  def run_namelist_tests(namelist, hash, enum = nil)
    ext = enum ? "_#{enum}" : ""
    hash[:must_pass].each do |tst|
      error(namelist_test_failed(namelist, tst)) unless instance_eval(tst[:test])
    end if hash[:must_pass]
    hash[:should_pass].each do |tst|
      warning(namelist_test_failed(namelist, tst)) unless instance_eval(tst[:test])
    end if hash[:should_pass]
    hash[:variables].each do |var, var_hash|
      cr_var = var+ext.to_sym 
      value = send(cr_var)
      if value.kind_of? Array
        value.each{|v| test_variable(namelist, var, var_hash, ext, v)}
      else
        test_variable(namelist, var, var_hash, ext, value)
      end
    end
  end

  def check_parameters
    rcp.namelists.each do |namelist, hash|
      next if hash[:should_include].kind_of? String and not eval(hash[:should_include])
      if en = hash[:enumerator]
        next unless send(en[:name])
        send(en[:name]).times do |i|
          run_namelist_tests(namelist, hash, i+1)
        end
      else
        run_namelist_tests(namelist, hash)
      end
    end

    # Now look at namelist specific flags, catch any obvious mistakes/conflicts
    
    ###################
    # in_out namelist #
    ###################
    
    if not (@write_h5 and @write_h5.fortran_true?) 
      warning("Very little analysis will be possible without write_h5 = '.true.'") 
    end

    if not (@write_checkpoint and @write_checkpoint.fortran_true?) and 
      not (@chpt_h5 and @chpt_h5.fortran_true?)
      p @write_checkpoint, @write_checkpoint.fortran_true?
      warning("This simulation will not write out a checkpoint file.")
    end

    if (@write_std and @write_std.fortran_true?) and (@write_h5 and @write_h5.fortran_true?)
      warning("Both write_std and write_h5 are specified - will produce lots of output!")
    end
  end

  def test_failed(namelist, var, gene_var, tst)
	return  <<EOF

---------------------------
	Test Failed
---------------------------

Namelist: #{namelist}	
Variable: #{var}
GENE Name: #{gene_var}
Value: #{send(var)}
Test: #{tst[:test]}
Explanation: #{tst[:explanation]}

---------------------------
EOF

  end


  def namelist_test_failed(namelist, tst)
	return  <<EOF

---------------------------
	Test Failed
---------------------------

Namelist: #{namelist}	
Test: #{tst[:test]}
Explanation: #{tst[:explanation]}

---------------------------
EOF

  end

  def test_variable(namelist, var, var_hash, ext, value)
    gene_var = (var_hash[:gene_name] or var)
    cr_var = var+ext.to_sym 
    if value and (not var_hash[:should_include] or  eval(var_hash[:should_include]))
        var_hash[:must_pass].each do |tst|
            error(test_failed(namelist, cr_var, gene_var, tst)) unless value.instance_eval(tst[:test])
        end if var_hash[:must_pass]
        var_hash[:should_pass].each do |tst|
            warning(test_failed(namelist, cr_var, gene_var, tst)) unless value.instance_eval(tst[:test])
        end if var_hash[:should_pass]
        if (var_hash[:allowed_values] or var_hash[:text_options])
            tst = {test: "#{(var_hash[:allowed_values] or var_hash[:text_options]).inspect}.include? self", explanation: "The variable must have one of these values"}
            error(test_failed(namelist, cr_var, gene_var, tst)) unless value.instance_eval(tst[:test])
        end
    end
  end
end
