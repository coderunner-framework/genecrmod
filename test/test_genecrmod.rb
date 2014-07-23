require 'helper'

class TestGenecrmod < Test::Unit::TestCase
  def test_read
    @runner = CodeRunner.fetch_runner(Y: 'test/linear_run/', A: true, C: 'gene')
    @runner.print_out(0)
  end
end
