require 'csv'
require 'open-uri'
require 'ruby-progressbar'

def check_args
  file = ARGV[0]

  if file.nil? 
    puts "Usage: ./tsv.rb [FILE]"
    exit 1
  end

  unless File.exist?(file)
    puts "[ERROR] Can't read file. File path = #{file}"
    exit 1
  end
end

def download_pdf(url,put_dir,title)
  filename = put_dir + '/' + title + '.pdf'
  content_length = nil
  progress_bar = nil

  open(url,"rb",
  :content_length_proc => lambda{ |content_length| 
    if content_length
      # プログレスバーの最大長にcontent-lengthを指定
      progress_bar = ProgressBar.create(:total => content_length)
    end
  },
  :progress_proc => lambda{ |transferred_bytes|
    if progress_bar
      # プログレスバーの進捗状況にこれまで転送されたバイト数を代入する
      progress_bar.progress = transferred_bytes
    else
      puts "#{transferred_bytes} / Total size is unknown"
    end
  }) do |file|
    open(filename,"w+b") do |out|
      out.write(file.read)
    end
  end
end

# main
check_args
file = ARGV[0]

csvDatas = CSV.read(file, col_sep: "\t", headers: true)
csvDatas.each do  |row|
  doi_url = row[17]
  
  dlurl = doi_url.sub('http://doi.org/','https://link.springer.com/content/pdf/')
  book_title = row[0]
  puts('StartDownload:'+book_title)
  download_pdf(dlurl,'./pdf',book_title)
  puts('Downloaded:'+book_title)
end
