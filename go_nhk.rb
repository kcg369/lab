# encoding: UTF-8
require "csv"

def get_csv(path, area)
  csv, code, target = [[], '', nil]
  CSV.foreach(path, encoding: "Shift_JIS:UTF-8", skip_blanks: true) {|r|    
    code, target = [r[2], r[9].match(area)] if code != r[2]
      
    if target && r[11] && r[12] then
        faddr = r[7]+r[9]+r[11]
        faddr += r[15] if r[15]
      #  puts r[12]+' '+faddr
        csv.push([r[12], faddr]) if faddr != csv[-1]
    end
  }
  return csv.uniq.sort
end

def roman_hash()
  roman = {}
  ["a,i,u,e,o,アイウエオ",
  "ka,ki,ku,ke,ko,カキクケコ",
  "sa,si,su,se,so,サシスセソ",
  "ta,ti,tu,te,to,タチツテト",
  "na,ni,nu,ne,no,ナニヌネノ",
  "ha,hi,hu,he,ho,ハヒフヘホ",
  "ma,mi,mu,me,mo,マミムメモ",
  "ya,   yu,   yo,ヤユヨ",
  "ra,ri,ru,re,ro,ラリルレロ",
  "wa,ワ"].each {|rm|
     iroha = rm.split(',')
     kana = iroha.pop
     ary = [iroha, kana.split(//)].transpose
     roman.merge!(Hash[*ary.flatten]) }
  return roman
end

def edit_csv(csv, scsv, dat)
  ps, count, opt, name, length = [0, 7, '', '', csv.length]
  roman = roman_hash()
  loop {
    print "#{ps}/#{length}"
    count.times {|c| name = csv[ps][1]; 
      print "\n"+name; print " *" if csv[ps][2]
      ps = (ps + 1) % length }
    print ': ';
    opt, token = STDIN.gets.chomp.encode('UTF-8').split
    if opt == nil then
      next
    elsif opt == 's' then
  #    csv.each {|d| scsv.push([0, d[1].encode('UTF-8')]) }
      break 
    elsif opt == 'p' then
      count = 7
    elsif opt == 'ls' then
      if token then
        s = token.to_i
        s = scsv.find_index {|ds| s <= ds[0] }
        scsv[s, 10].each {|se| puts "#{se[0]} #{se[1]}" }
      else
        s = e = scsv[0][0]
        scsv[1..-1].each {|se|
          if e+1 == se[0]
            e = se[0]
          else
            print s == e ? "#{s} " : "#{s}-#{e} "
            s = e = se[0]
          end
        }
        puts s == e ? "#{s}" : "#{s}-#{e}"
      end
      ps -= count
    elsif opt == 'd' then
      scsv.delete_if {|se| se[0] == token.to_i } if token
      ps -= count
    elsif opt == 't' then
        ps, count = [(ps - 7) % length, 1] 
    elsif opt.include?('/')
      off = ['/','//','///','1/','2/','3/','4/','5/'].find_index(opt)
      if off then
        off = [2, 3, 4, 7, 6, 5, 4, 3][off]
        ps, count = [(ps - off) % length, 1] end
    elsif roman[opt] then
      roman_reg = /^#{roman[opt]}/
      ps = csv.find_index {|r| r[0].match(roman_reg) } - 4
      count = 7
    else
      [opt, token].flatten.compact.each {|no|
        if no.include?('-')
          f, e = no.split('-').map {|n| n.to_i }
          f.step(e) {|n|
            scsv.push([n, name+dat[n-1].gsub('t','丁目')])
            no, labs = scsv[-1]; puts " > #{no} #{labs}" }
        else
          n = no.to_i
          scsv.push([n, name+dat[n-1].gsub('t','丁目')])
          no, labs = scsv[-1]; puts " > #{no} #{labs}" 
        end
        csv[ps-1][2] = '*'
        scsv = scsv.sort
      }
      count = 1
    end
  }
  scsv.sort
end

def put_csv(path, csv)
  File.open(path, "w", 0755) {|f| f.print csv.map{|r| r.join(',') }.join("\n") }
end

path, area, dat_path = ARGV
if area then
  dsv_path = area+'.dsv'
  dat_path = area+'.dat' if !dat_path
  dsv = File.exist?(dsv_path) ? 
          CSV.read(dsv_path, encoding: "UTF-8").map {|ds| ds[0] = ds[0].to_i; ds} : []
  dat = CSV.read(dat_path).flatten
  csv = edit_csv(get_csv(path, area.encode('UTF-8')), dsv, dat)
  put_csv(dsv_path, csv)
else
  put_csv(File.basename(path, '.*')+'.csv', [["番号","名称","住所"]]+
    CSV.read(path, encoding: "UTF-8").uniq.map {|r| 
      [r[0].to_i, r[0]+' '+r[1].split('町')[1], r[1]]}.sort)
end
# p roman_hash["p"]

