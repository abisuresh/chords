require 'securerandom'
class InputDatum < ApplicationRecord
   has_one_attached :input_netcdf
   has_one_attached :plot_file

   def convert_netcdf_to_plot_file
      #create a temp file with random name
      tmp_directory = File.join(Rails.root, 'tmp')
      temp_file_name = SecureRandom.uuid + '.netcdf'
      @image_file = SecureRandom.uuid
      full_image_path = @image_file + "cartesian_gridded_zh.png"
      # @temp_file_path = "/Users/suresha/databaseVersionApp/app/controllers/#{temp_file_name}"
      @temp_file_path = "#{tmp_directory}/#{temp_file_name}"

      #get controller object
      # input_data_id = 1
      # input_data_object = InputDatum.find(input_data_id)

      #downloading and saving data in file to a new variable 
      data = self.input_netcdf.download

      #file write data 
      File.open(@temp_file_path, "wb"){|file| file.write data}

      #call the python script that converts an input netcdf data
      #to a PNG plot
      @python_output = `python /Users/suresha/databaseVersionApp/lib/assets/python/make_and_plot_grid.py #{@temp_file_path} #{full_image_path}`

      #attach output plot file
      self.plot_file.attach(io: File.open(full_image_path), filename: File.basename(full_image_path), content_type: "image/png")

      #delete full image path and temp file
      File.delete(@temp_file_path)
      File.delete(full_image_path) 
   end
end
