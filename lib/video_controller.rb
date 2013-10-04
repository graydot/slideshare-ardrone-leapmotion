class VideoController
  IMAGE_COUNT = 20
  def finish
    puts 'finish'
    File.delete('/Users/jemmanue/Desktop/upload.pdf')
    `automator Automator.app`
    # upload 
    conf = YAML.load_file('slideshare_credentials.yml')
    
    api_key = conf["api_key"]
    shared_secret = conf["shared_secret"]
    username = conf["username"]
    password = conf["password"]
    file_path = "/Users/jemmanue/Desktop/upload.pdf"
    now = Time.now.to_i.to_s
    hashed = Digest::SHA1.hexdigest("#{secret}#{now}")
    curl_return = `curl -F slideshow_srcfile=@#{file_path} -F username=#{username} -F password=#{password} -F slideshow_title='ARDrone Slideshow Upload - Slideshare Hackday' https://www.slideshare.net/api/2/upload_slideshow -F api_key=#{api_key} -F ts=#{now} -F hash=#{hashed}`
    begin
      response = XmlSimple.xml_in(curl_return)
      id = response["SlideShowID"].first
    rescue
    end
    converted = false
    while !converted
      puts "Getting status for #{id}"
      curl_return = `curl -F slideshow_id=#{id} https://www.slideshare.net/api/2/get_slideshow -F api_key=#{api_key} -F ts=#{now} -F hash=#{hashed}`
      response = XmlSimple.xml_in(curl_return)
      status = response["Status"].first.to_i rescue 0
      if status == 3
        converted = true
      elsif status == 2
        converted = true
        url = response["URL"].first
        `open #{url}`
      end
      sleep(1)
    end
  end
  def initialize(mode = 1)
    socket = TCPSocket.open('192.168.1.1', 5555)
    streamer = Argus::VideoStreamer.new(:socket => socket)
    filename = "#{Time.now.to_i}.h246"
    h246_out = File.new(filename, "w+b")
    streamer.start
    video_done = false
    t1 =Thread.new do
      puts "stream thread"
      while !video_done do
        h246_out.write streamer.receive_data.frame rescue nil
        sleep 0.01
      end
    end
    t1.abort_on_exception = true
    
    output_iters = 0
    Dir.glob('*.jpeg').each do |file|
      File.delete(file)
    end
    
    t2 = Thread.new do
      puts "process thread thread"
      if mode == 1
        sleep_dur = 20
      else
        sleep_dur = 100
      end
      sleep(sleep_dur)
      puts "processor ============================================== #{output_iters}"
      fout = `ffmpeg -i #{filename} -y -r 0.5 -f image2 image%5d.jpeg`
      output_iters += 1
      video_done = true
      puts "out of ffmpeg"
      # create a pdf
      files = Dir.glob('*.jpeg')
      fl = files.length
      puts "1"
      if fl > IMAGE_COUNT
        # work on reducing files
        start = (fl/5).to_i
        stop = fl-1
        diff = stop - start
        puts "2"
        if  diff > IMAGE_COUNT
          # reduce further
          step = diff/IMAGE_COUNT
          selected_files = []
          (start..stop).step(step) do |pos|
            pos = pos.to_i
            selected_files << files[pos] if files[pos]
          end
          puts 3
        else
          puts 4
          selected_files = files[start, IMAGE_COUNT]
        end
      else
        puts 5
        selected_files = files
      end
      
      (files - selected_files).each do|file|
        File.delete(file)
      end
      finish
    end
    t2.abort_on_exception = true
    t1.join
    t2.join
  end
  
end