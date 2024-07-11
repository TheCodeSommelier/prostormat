# frozen_string_literal: true

require 'open-uri'

puts 'Cleaning DB...'

Filter.destroy_all

puts 'Creating places...'

Dir.mkdir('place_images')

USER = User.find_by(email: 'poptavka@prostormat.cz')

PLACES = [{
  place_name: 'Bohemia Goose',
  capacity: 200,
  street: 'Vodičkova',
  house_number: '682/20',
  postal_code: '110 00',
  city: 'Praha',
  image_links: ['https://www.bohemiagoose.cz/wp-content/uploads/2023/05/home_gallery_01.jpg', 'https://www.bohemiagoose.cz/wp-content/uploads/2023/05/home_gallery_04.jpg', 'https://www.bohemiagoose.cz/wp-content/uploads/2023/05/home_gallery_03.jpg', 'https://www.bohemiagoose.cz/wp-content/uploads/2023/05/home_gallery_08.jpg', 'https://www.bohemiagoose.cz/wp-content/uploads/2023/05/home_slider_1b.jpg']
},
          {
            place_name: 'Asian Temple',
            capacity: 400,
            street: 'Bílkova',
            house_number: '864',
            postal_code: '110 00',
            city: 'Praha',
            image_links: ['https://www.asiantemple.cz/wp-content/uploads/2022/02/rest4.jpeg', 'https://www.asiantemple.cz/wp-content/uploads/2022/02/bar1.jpeg', 'https://www.asiantemple.cz/wp-content/uploads/2022/02/lounge5.jpeg', 'https://www.asiantemple.cz/wp-content/uploads/2022/02/rest2.jpeg', 'https://www.asiantemple.cz/wp-content/uploads/2022/02/rest3.jpeg', 'https://www.asiantemple.cz/wp-content/uploads/2022/02/ter1.jpeg']
          },
          {
            place_name: 'La Casa Latina',
            capacity: 250,
            street: 'Dlouhá',
            house_number: '35',
            postal_code: '110 00',
            city: 'Praha',
            image_links: ['https://www.lacasalatina.cz/wp-content/uploads/2024/04/22.jpg', 'https://www.lacasalatina.cz/wp-content/uploads/2024/04/8-2.jpg', 'https://www.lacasalatina.cz/wp-content/uploads/2024/04/7-2.jpg', 'https://www.lacasalatina.cz/wp-content/uploads/2024/04/2-2.jpg', 'https://www.lacasalatina.cz/wp-content/uploads/2024/04/3-2.jpg', 'https://www.lacasalatina.cz/wp-content/uploads/2024/04/21.jpg']
          },
          {
            place_name: 'Antricote',
            capacity: 35,
            street: 'Břehová',
            house_number: '274/5',
            postal_code: '110 00',
            city: 'Praha',
            image_links: ['https://antricote.com/_next/image?url=%2Fgallery%2F1.webp&w=3840&q=75', 'https://antricote.com/_next/image?url=%2Fgallery%2F2.webp&w=3840&q=75', 'https://antricote.com/_next/image?url=%2Fgallery%2F3.webp&w=3840&q=75', 'https://antricote.com/_next/image?url=%2Fgallery%2F5.webp&w=3840&q=75', 'https://antricote.com/_next/image?url=%2Fgallery%2F6.webp&w=3840&q=75', 'https://antricote.com/_next/image?url=%2Fgallery%2F8.webp&w=3840&q=75']
          },
          {
            place_name: 'Bodeguita Del Medio',
            capacity: 200,
            street: 'Kaprova',
            house_number: '19/5',
            postal_code: '110 00',
            city: 'Praha',
            image_links: ['https://www.labodeguitadelmedio.cz/admin/pictures/medium_s/DSCF5625_6355956e9bc1c.jpg', 'https://www.labodeguitadelmedio.cz/admin/pictures/medium_s/DSCF5644_63559572bf76b.jpg', 'https://www.labodeguitadelmedio.cz/admin/pictures/medium_s/DSCF5460_635595b9c8bc9.jpg', 'https://www.labodeguitadelmedio.cz/admin/pictures/medium_s/IMG_0966_66799c0546944.jpg', 'https://www.labodeguitadelmedio.cz/admin/pictures/orig/DSCF5798_635592393e523.jpg', 'https://www.labodeguitadelmedio.cz/admin/pictures/medium_s/DSCF5666_6355920a0db32.jpg', 'https://www.labodeguitadelmedio.cz/admin/pictures/medium_s/DSCF5546_6355902fa4dd1.jpg']
          },
          # ****
          {
            place_name: 'One Club Prague',
            capacity: 600,
            street: 'Melantrichova',
            house_number: '504/5',
            postal_code: '110 00',
            city: 'Praha',
            # image_links: ['https://www.google.com/imgres?q=One%20Club%20Prague&imgurl=https%3A%2F%2Fstatic.wixstatic.com%2Fmedia%2F194886_d5543fa84e0844c9af5efb6501735a86~mv2_d_1920_1280_s_2.jpg%2Fv1%2Ffit%2Fw_2500%2Ch_1330%2Cal_c%2F194886_d5543fa84e0844c9af5efb6501735a86~mv2_d_1920_1280_s_2.jpg&imgrefurl=https%3A%2F%2Fwww.oneclubprague.cz%2F&docid=d-9naE_rGI1G4M&tbnid=0jN70UnfMrTTiM&vet=12ahUKEwiNv6W36JaHAxUXUEEAHeznDdMQM3oECFAQAA..i&w=1920&h=1280&hcb=2&ved=2ahUKEwiNv6W36JaHAxUXUEEAHeznDdMQM3oECFAQAA', 'https://www.google.com/imgres?q=One%20Club%20Prague&imgurl=https%3A%2F%2Fstatic.wixstatic.com%2Fmedia%2F194886_1c8fac56c52e4e16b4feb4283a43e489~mv2.jpg%2Fv1%2Ffill%2Fw_280%2Ch_178%2Cal_c%2Cq_80%2Cusm_0.66_1.00_0.01%2Cenc_auto%2F194886_1c8fac56c52e4e16b4feb4283a43e489~mv2.jpg&imgrefurl=https%3A%2F%2Fwww.oneclubprague.cz%2F&docid=d-9naE_rGI1G4M&tbnid=2ECa_c7OCkKHMM&vet=12ahUKEwiNv6W36JaHAxUXUEEAHeznDdMQM3oECFgQAA..i&w=280&h=178&hcb=2&ved=2ahUKEwiNv6W36JaHAxUXUEEAHeznDdMQM3oECFgQAA', 'https://www.google.com/imgres?q=One%20Club%20Prague&imgurl=https%3A%2F%2Fstatic.wixstatic.com%2Fmedia%2F194886_57a2cddd4d694059bd0f3ef628e68e5b~mv2_d_5173_3449_s_4_2.jpg%2Fv1%2Ffill%2Fw_560%2Ch_372%2Cal_c%2Cq_80%2Cusm_0.66_1.00_0.01%2Cenc_auto%2FIMG_2897.jpg&imgrefurl=https%3A%2F%2Fwww.oneclubprague.cz%2Fcocktail-masterclass&docid=qYc9l-sk2o-kuM&tbnid=jlp2_uhQUc5AOM&vet=12ahUKEwiNv6W36JaHAxUXUEEAHeznDdMQM3oFCIEBEAA..i&w=560&h=372&hcb=2&ved=2ahUKEwiNv6W36JaHAxUXUEEAHeznDdMQM3oFCIEBEAA', 'https://www.google.com/imgres?q=One%20Club%20Prague&imgurl=https%3A%2F%2Fmedia-cdn.tripadvisor.com%2Fmedia%2Fphoto-s%2F13%2F9f%2F8d%2F3c%2Fnew-photos-of-one-club.jpg&imgrefurl=https%3A%2F%2Fwww.tripadvisor.com.tr%2FLocationPhotoDirectLink-g274707-d10522864-i329223497-One_Club_Prague-Prague_Bohemia.html&docid=hbU7cj9H2mta6M&tbnid=jVvMl9RTvzArrM&vet=12ahUKEwieq4-i6ZaHAxUpRkEAHaT_C_E4ChAzegQITBAA..i&w=550&h=367&hcb=2&ved=2ahUKEwieq4-i6ZaHAxUpRkEAHaT_C_E4ChAzegQITBAA']
          },
          {
            place_name: 'FU Club & Lounge',
            capacity: 500,
            street: 'Dlouhá',
            house_number: '741/13',
            postal_code: '110 00',
            city: 'Praha',
            image_links: ['https://www.fuclublounge.com/wp-content/uploads/2023/11/AFI_9419-1-scaled.jpg', 'https://www.fuclublounge.com/wp-content/uploads/2023/11/AFI_9457-1-scaled.jpg', 'https://www.fuclublounge.com/wp-content/uploads/2023/11/AFI_9516-scaled.jpg', 'https://www.fuclublounge.com/wp-content/uploads/2023/11/AFI_9471-1-scaled.jpg', 'https://www.fuclublounge.com/wp-content/uploads/2023/11/AFI_9351_HDR-1-scaled.jpg', 'https://www.fuclublounge.com/wp-content/uploads/2023/12/MK004-scaled.jpg', 'https://www.fuclublounge.com/wp-content/uploads/2023/11/MK007-scaled.jpg', 'https://www.fuclublounge.com/wp-content/uploads/2023/11/MK049-scaled.jpg']
          },
          # ****
          {
            place_name: 'M1 Lounge',
            capacity: 130,
            street: 'Masná',
            house_number: '1',
            postal_code: '110 00',
            city: 'Praha'
          },
          {
            place_name: 'Pop Up Bar',
            capacity: 120,
            street: 'Na Příkopě',
            house_number: '390/3',
            postal_code: '110 00',
            city: 'Praha',
            image_links: ['https://popup-bar.cz/wp-content/uploads/2024/03/DSC05102-min-scaled.jpg', 'https://popup-bar.cz/wp-content/uploads/2024/03/DSC05024-min-scaled.jpg', 'https://popup-bar.cz/wp-content/uploads/2024/06/PIC08862-min-scaled.jpg', 'https://popup-bar.cz/wp-content/uploads/2024/06/PIC09300-min-scaled.jpg', 'https://popup-bar.cz/wp-content/uploads/2024/06/PIC09307-min-scaled.jpg']
          },
          {
            place_name: 'Epic Club',
            capacity: 1000,
            street: 'Revoluční',
            house_number: '1003/3',
            postal_code: '110 00',
            city: 'Praha',
            image_links: ['https://www.epicprague.com/galerie/foto/66105#no-redirect', 'https://www.epicprague.com/galerie/foto/66138#no-redirect', 'https://www.epicprague.com/galerie/foto/66162#no-redirect', 'https://www.epicprague.com/galerie/foto/66112#no-redirect', 'https://www.epicprague.com/galerie/foto/66104#no-redirect', 'https://www.epicprague.com/galerie/foto/66239#no-redirect', 'https://www.epicprague.com/galerie/foto/66272#no-redirect']
          },
          {
            place_name: 'Malvaz Restaurant',
            capacity: 120,
            street: 'Maiselova',
            house_number: '38/15',
            postal_code: '110 00',
            city: 'Praha',
            image_links: ['https://umalvaze.cz/wp-content/uploads/2024/05/DSC2497.jpg', 'https://umalvaze.cz/wp-content/uploads/2024/05/DSC2554-1.jpg', 'https://umalvaze.cz/wp-content/uploads/2024/05/DSC2568.jpg', 'https://umalvaze.cz/wp-content/uploads/2024/05/DSC2618.jpg', 'https://umalvaze.cz/wp-content/uploads/2024/05/DSC2846.jpg']
          },
          # ****
          {
            place_name: '80s Club',
            capacity: 400,
            street: 'V Kolkovně',
            house_number: '909/6',
            postal_code: '110 00',
            city: 'Praha'
          },
          {
            place_name: 'Dutch Pub',
            capacity: 150,
            street: 'Vladislavova',
            house_number: '1390/17',
            postal_code: '110 00',
            city: 'Praha',
            image_links: ['https://www.dutchpub.cz/admin/pictures/medium_s/Dutch_Pub-89.jpg', 'https://www.dutchpub.cz/admin/pictures/medium_s/Dutch_Pub_best_of-26.jpg', 'https://www.dutchpub.cz/admin/pictures/medium_s/DUTCasdH_PUB_-_011.jpg', 'https://www.dutchpub.cz/admin/pictures/medium_s/DUTCfadfH_PUB_-_022.jpg', 'https://www.dutchpub.cz/admin/pictures/orig/Dutch_Pub-86.jpg']
          },
          {
            place_name: 'Moon Club',
            capacity: 600,
            street: 'Dlouhá',
            house_number: '709/26',
            postal_code: '110 00',
            city: 'Praha',
            image_links: ['https://www.instagram.com/moonclub_prague/', 'https://www.instagram.com/moonclub_prague/', 'https://www.instagram.com/moonclub_prague/', 'https://www.instagram.com/moonclub_prague/', 'https://www.instagram.com/moonclub_prague/']
          },
          # ****
          {
            place_name: 'KU Club & Bar',
            capacity: 120,
            street: 'Rytířská',
            house_number: '13',
            postal_code: '110 00',
            city: 'Praha',
            image_links: []
          },
          # ****
          {
            place_name: 'Steampunk Prague',
            capacity: 200,
            street: 'V Kolkovně',
            house_number: '920/5',
            postal_code: '110 00',
            city: 'Praha'
          }].freeze

# Add pictures to places
PLACES.each do |place_hash|
  next if Place.find_by(place_name: place_hash[:place_name])

  place = Place.new(place_hash.except(:image_links))
  place.user = USER
  place_hash[:image_links].each_with_index do |image_link, index|
    open("place_images/image_#{index}.jpg", 'wb') do |file|
      file << open(image_link).read
    end
    place.photos.attach(File.read("image_#{index}.png"))
    File.delete("image_#{index}.png")
  end
  place.save
end

Dir.rmdir('place_images')

# Filters
FILTER_NAMES = %w[bar restaurant hotel indoor outdoor wedding industrial].freeze

FILTER_NAMES.each do |filter|
  Filter.create(name: filter)
end

puts 'Done ✅'
