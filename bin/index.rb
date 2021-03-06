def scan_info(man_path)
  key_words = [ "SUMMARY", "DESCRIPTION", 
                "INTRODUCTION", "ENVIRONMENT"]
  File.open("#{man_path}", "r") do |infile|
    # read the file line by line
    while(line = infile.gets)
      # if it's in the NAME section 
      if(line.include?("NAME\n"))
        # read the second line
        while(line << infile.gets)
          break line if(line["\n\n"])
        end
        $name = line.gsub(/["\n","\t"]/, ' ').squeeze(' ').split("-", 2).last.lstrip
      end
      # if there's a key word for discription
      if(key_words.any? { |token| line.include? token } ) 
        # read until there's an empty line
        while(line << infile.gets)
          break line if(line["\n\n"])
        end 
        line = line.split(" ", 2).last.lstrip
        # if line is less than 30 words
        if(line.split.size <= 30)
          $discription = line
          break
        # else cut it so it's 30 words
        else
          # join the array
          $discription = line.split[0..29].join(" "). + "..."
          break
        end
      end
    end
  end
  # remove multiple spaces/tab and new lines inside of strings
  $discription = $discription.to_s.gsub(/["\n","\t"]/, ' ').squeeze(' ')
  $name = $name.to_s.gsub(/["\n","\t"]/, ' ').squeeze(' ')
end

$output = File.new("index.html", "w")
$list = Dir["./man/**/*.txt"]
$i = 0

$output.print File.read("./lib/include/index_start")

# iteration for the mans
begin
  $discription = String.new
  $name = String.new
  scan_info($list[$i])
  $title = File.basename("#{$list[$i]}", ".*" )
  $output.print("<div class=\"section\">" +
               "<div class=\"title\"><a href=\"#{$list[$i]}\">#{$title}" +
               "</a></div><p class=\"name\"><b>#{$name}</b></p>" +
               "<div class=\"discription\">#{$discription}</p>" + 
               "</div></div>") 
  $i = $i + 1
end until($i > $list.size - 1)

$output.print File.read("./lib/include/index_end")

