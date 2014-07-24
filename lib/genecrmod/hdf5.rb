require 'hdf5'
class CodeRunner::Gene
  def get_h5_narray_all(file, dataset)
    Dir.chdir(@directory) do
      file = Hdf5::H5File.new(file)
      narray =  file.dataset(dataset).narray_all
			file.close
			return narray
    end
  end
end
