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

    filename = ARGV[0]

    # verifica se o arquivo existe
    unless File.file?(filename)
        puts "\033[31mO arquivo \"\033[31;1m" + filename + "\033[0m\033[31m\" não existe."
        exit()
    end

    lex = Lex.new(filename)
    sem = Semantic.new(lex)
    syn = Syntactic.new(lex, sem)

    syn.run()
    sem.save(File.basename(filename, File.extname(filename)))

    puts "Lexic table:"
    Pry::ColorPrinter.pp(lex.table)
end 