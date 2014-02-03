class Scrapper

  def self.make_absolute( href, root )
    URI.parse(root).merge(URI.parse(href)).to_s
  end

  # check the specifc site folder exists If it's reuse or else create the new directory with that url name
  def self.check_folder_exists_and_create name
    folder_exists = Dir.exists?("#{Rails.root}/app/assets/images/#{name}")
    Dir.mkdir("#{Rails.root}/app/assets/images/#{@file_header}") if !folder_exists
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
    site_info = Nokogiri::HTML(open(params[:search_url]))
    content_data[:title] = site_info.css("title")[0].text
    if params[:page].present?
      images = fetch_images_from_directory folder_name
    else
      images = []
      site_info.xpath("//img/@src").each_with_index do |src, index|
        uri = make_absolute(src,params[:search_url])
        image_data = download_images folder_name, uri, index
        images.push image_data
      end
    end
    @images = Kaminari.paginate_array(images).page(params[:page]).per(PER_PAGE)
   return @images,content_data
  end

end


