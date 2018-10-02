require "./lex.rb"
require "pry"

if $PROGRAM_NAME == __FILE__  
    # verifica se o arquivo foi passado como parâmetro
    if ARGV.length < 1
        puts "\033[31;1mPasse o arquivo de entrada como argumento."
        exit()
    end

    # verifica se o arquivo existe
    unless File.file?(ARGV[0])
        puts "\033[31mO arquivo \"\033[31;1m" + ARGV[0] + "\033[0m\033[31m\" não existe."
        exit()
    end

    lex = Lex.new(ARGV[0])
  
    loop do
        # chamada do léxico que retorna uma hash {:lexeme, :token, :type}
        tuple = lex.get()

        break unless tuple
        Pry::ColorPrinter.pp(tuple)
    end

    #Pry::ColorPrinter.pp(lex.table)
end 