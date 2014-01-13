(1..20).map{|i|i%3<1&&x=:Fizz;i%5<1?"#{x}Buzz":x||i}.map(&:to_s.to_proc)
