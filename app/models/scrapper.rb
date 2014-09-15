class Scrapper

  def self.make_absolute( href, root )
    URI.parse(root).merge(URI.parse(href)).to_s
  end

  # check the specifc site folder exists If it's reuse or else create the new directory with that url name
  def self.check_folder_exists_and_create name
    folder_exists = Dir.exists?("#{Rails.root}/app/assets/images/#{name}")
    Dir.mkdir("#{Rails.root}/app/assets/images/#{name}") if !folder_exists
    return folder_exists
  end


  def self.fetch_images_from_directory dir_name
    @image_files = Dir.entries("#{Rails.root}/app/assets/images/#{dir_name}").map{|name|  "#{dir_name}/#{name}"}
    return  @image_files
  end

  def self.download_images folder_name, url, index
    extn = url.split('.').last || "jpg"
    file_name = "img#{index+1}.#{extn}"
    File.open(File.join(Rails.root, 'app', 'assets', 'images',folder_name, File.basename(file_name)),'wb'){ |f|
      f.write(open(url).read)
    }
    return folder_name+'/'+ File.basename(file_name)
  end


  def self.fetch_data params
    folder_name = URI.parse(params[:search_url]).host.gsub(/www\./, '').gsub('.', '_')
    check_folder_exists_and_create folder_name
    content_data = {}
    #debugger
    begin
      site_info = Nokogiri::HTML(open(params[:search_url]))
      content_data[:title] = site_info.css("title")[0].text
      if params[:page].present?
        images = fetch_images_from_directory folder_name
      else
        images = []
        site_info.xpath("//img/@src").each_with_index do |src, index|
          uri = make_absolute(src,params[:search_url])
          begin
            image_data = download_images folder_name, uri, index
            images.push image_data
          rescue
            next
          end

        end
      end
    rescue  RuntimeError,SocketError => error_msg
      error_msg = error_message_notifier(error_msg.class)
    end

    @images = images.present? ?  Kaminari.paginate_array(images).page(params[:page]).per(PER_PAGE) : error_msg
    return @images,content_data
  end

  def self.error_message_notifier type
   error_hash = Hash[SocketError,"Entered Web URL is not available...",RuntimeError,"Problem with connecting the Remote site..."]
   error_msg =  error_hash[type].present? ? error_hash[type] : "Problem with Fetching Images"
   return error_msg
  end

end


