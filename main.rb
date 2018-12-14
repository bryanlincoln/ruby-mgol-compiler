require "./lex.rb"
require "./syntactic.rb"
require "./semantic.rb"
require "pry"

if $PROGRAM_NAME == __FILE__  
    # verifica se o arquivo foi passado como parâmetro
    if ARGV.length < 1
        puts "\033[31;1mPasse o arquivo de entrada como argumento.\033[0m"
        exit()
    end

    # verifica se o arquivo existe
    unless File.file?(ARGV[0])
        puts "\033[31mO arquivo \"\033[31;1m" + ARGV[0] + "\033[0m\033[31m\" não existe."
        exit()
    end

    lex = Lex.new(ARGV[0])
    sem = Semantic.new(lex)
    syn = Syntactic.new(lex, sem)

    syn.run()
    sem.save()

    # Pry::ColorPrinter.pp(lex.table)
end 