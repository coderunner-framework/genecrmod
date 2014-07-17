
#p 'eeee'
require 'helper'
CodeRunner.setup_run_class('gene')
#CodeRunner::Chease.get_input_help_from_source_code(ENV['GENE_SOURCE'])
#CodeRunner::Chease.update_defaults_from_source_code(ENV['GENE_SOURCE'])
CodeRunner::Gene.synchronise_variables(ENV['GENE_SOURCE'])
