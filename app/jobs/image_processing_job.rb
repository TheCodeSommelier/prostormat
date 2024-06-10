# frozen_string_literal: true

class ImageProcessingJob < ApplicationJob
  queue_as :default

  def perform(photos_data, place_id)
    place = Place.find(place_id.to_i)

    photos_data.each do |photo_data|
      next if photo_data.blank?

      temp_file = decode_base64_to_tempfile(photo_data)
      processed_image = process_image(temp_file.path)
      attach_processed_image(place, processed_image, photo_data[:filename], photo_data[:content_type])
      temp_file.close
      temp_file.unlink
    end
  end

  private

  def decode_base64_to_tempfile(data)
    temp_file = Tempfile.new([data[:filename].split('.').first, ".#{data[:filename].split('.').last}"])
    temp_file.binmode
    temp_file.write(Base64.decode64(data[:base64]))
    temp_file.rewind
    temp_file
  end

  def process_image(image_path)
    image = MiniMagick::Image.open(image_path)
    image.quality '60'
    image.depth '8'
    image.interlace 'plane'
    image
  end

  def attach_processed_image(place, processed_image, filename, content_type)
    temp_file = Tempfile.new(['processed', File.extname(filename)])
    temp_file.binmode
    processed_image.write(temp_file.path)
    temp_file.rewind

    place.photos.attach(io: temp_file, filename: filename, content_type: content_type)

    temp_file.close
    temp_file.unlink
  end
end
