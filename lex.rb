class Lex
    attr_accessor :start, :end, :transition, :state, :tokens, :file, :file_line, :file_col, :table

    def initialize(file)
        # tabela de transições
        @transition = { 
            :ini  => {
                "0" => :d, "1" => :d, "2" => :d, "3" => :d, "4" => :d, "5" => :d, "6" => :d, "7" => :d, "8" => :d, "9" => :d, 
                "+" => :o, "-" => :o, "*" => :o, "/" => :o,
                "\"" => :l,
                "a" => :i, "b" => :i, "c" => :i, "d" => :i, "e" => :i, "f" => :i, "g" => :i, "h" => :i, "i" => :i, "j" => :i, 
                "k" => :i, "l" => :i, "m" => :i, "n" => :i, "o" => :i, "p" => :i, "q" => :i, "r" => :i, "s" => :i, "t" => :i, 
                "u" => :i, "v" => :i, "x" => :i, "w" => :i, "y" => :i, "z" => :i,
                "{" => :c,
                ">" => :r1, "=" => :r2, "<" => :r3,
                "(" => :p1, ")" => :p2,
                ";" => :v,
                " " => :ini, "\n" => :ini, "\t" => :ini,
                "eof" => :f
            },
            :d    => {
                "0" => :d, "1" => :d, "2" => :d, "3" => :d, "4" => :d, "5" => :d, "6" => :d, "7" => :d, "8" => :d, "9" => :d,
                "." => :d1,
                "e" => :d2, "E" => :d2
            },
            :d1   => {
                "0" => :d11, "1" => :d11, "2" => :d11, "3" => :d11, "4" => :d11, "5" => :d11, "6" => :d11, "7" => :d11, "8" => :d11, "9" => :d11
            },
            :d2   => {
                "0" => :d21, "1" => :d21, "2" => :d21, "3" => :d21, "4" => :d21, "5" => :d21, "6" => :d21, "7" => :d21, "8" => :d21, "9" => :d21,
                "+" => :d22, "-" => :d22
            },
            :d11  => {
                "0" => :d11, "1" => :d11, "2" => :d11, "3" => :d11, "4" => :d11, "5" => :d11, "6" => :d11, "7" => :d11, "8" => :d11, "9" => :d11,
                "e" => :d2 # isso faz aceitar 5.2e-10, por exemplo - deve?
            },
            :d21  => {
                "0" => :d21, "1" => :d21, "2" => :d21, "3" => :d21, "4" => :d21, "5" => :d21, "6" => :d21, "7" => :d21, "8" => :d21, "9" => :d21
            },
            :d22  => {
                "0" => :d21, "1" => :d21, "2" => :d21, "3" => :d21, "4" => :d21, "5" => :d21, "6" => :d21, "7" => :d21, "8" => :d21, "9" => :d21
            },
            :l    => {
                "." => :l,
                "\"" => :l1
            },
            :l1   => {},
            :i    => {
                "0" => :i, "1" => :i, "2" => :i, "3" => :i, "4" => :i, "5" => :i, "6" => :i, "7" => :i, "8" => :i, "9" => :i,
                "a" => :i, "b" => :i, "c" => :i, "d" => :i, "e" => :i, "f" => :i, "g" => :i, "h" => :i, "i" => :i, "j" => :i, 
                "k" => :i, "l" => :i, "m" => :i, "n" => :i, "o" => :i, "p" => :i, "q" => :i, "r" => :i, "s" => :i, "t" => :i, 
                "u" => :i, "v" => :i, "x" => :i, "w" => :i, "y" => :i, "z" => :i,
                "_" => :i
            },
            :c    => {
                "." => :c,
                "}" => :c1
            },
            :c1   => {},
            :f    => {},
            :r1   => {
                "=" => :r11
            },
            :r11  => {},
            :r2   => {},
            :r3   => {
                ">" => :r32,
                "=" => :r31,
                "-" => :a
            },
            :r31  => {},
            :r32  => {},
            :a    => {},
            :o    => {},
            :p1   => {},
            :p2   => {},
            :v    => {},
        }
        # estado inicial
        @start = :ini
        @state = @start
        # estados finais
        @end = [:d, :d11, :d21, :l1, :i, :c1, :f, :r1, :r11, :r2, :r3, :r31, :r32, :a, :o, :p1, :p2, :v]
        # tokens correspondentes aos estados finais
        @tokens = {
            :d  => "Num", :d11 => "Num", :d21 => "Num", 
            :l1 => "Literal", 
            :i  => "id", 
            :c1 => "Comentário", 
            :f  => "EOF", 
            :r1 => "OPR", :r11 => "OPR", :r2 => "OPR", :r3 => "OPR", :r31 => "OPR", :r32 => "OPR", 
            :a  => "RCB", 
            :o  => "OPM", 
            :p1 => "AB_P", 
            :p2 => "FC_P", 
            :v  => "PT_V"
        }

        # abre o arquivo e inicializa as variáveis das linhas/colunas
        @file = File.open(file, 'r')
        if @file.closed?
            puts "Erro ao abrir o arquivo."
        end
        @file_line = @file_col = 1

        # tabela de símbolos
        @table = {
            :inicio     => { :lexeme => "inicio", :token => "keyword", :type => "-" },
            :varinicio  => { :lexeme => "varinicio", :token => "keyword", :type => "-" },
            :varfim     => { :lexeme => "varfim", :token => "keyword", :type => "-" },
            :escreva    => { :lexeme => "escreva", :token => "keyword", :type => "-" },
            :leia       => { :lexeme => "leia", :token => "keyword", :type => "-" },
            :se         => { :lexeme => "se", :token => "keyword", :type => "-" },
            :entao      => { :lexeme => "entao", :token => "keyword", :type => "-" },
            :fimse      => { :lexeme => "fimse", :token => "keyword", :type => "-" },
            :fim        => { :lexeme => "fim", :token => "keyword", :type => "-" },
            :inteiro    => { :lexeme => "inteiro", :token => "keyword", :type => "-" },
            :lit        => { :lexeme => "lit", :token => "keyword", :type => "-" },
            :real       => { :lexeme => "real", :token => "keyword", :type => "-" }
        }
    end

    def run(input)
        # casos especiais do .
        if @state == :c and input != "}"
            input = "."
        elsif @state == :l and input != "\""
            input = "."
        end

        # verifica se o caractere lido é reconhecido pelo dfa no estado atual
        unless @transition[@state][input.downcase]
            # senão, verifica se o estado atual é final
            if @end.include? @state
                # traduz o token
                token = @tokens[@state]
                # reseta o dfa
                @state = :ini

                return token
            end

            # se não for, ocorreu um erro
            return false
        end

        # se o caractere é reconhecido, atualiza o estado e continua
        @state = @transition[@state][input.downcase]

        return true
    end

    def get()
        # buffer do lexema
        lexeme = ""

        loop do
            # get depois que o arquivo já foi fechado
            if @file.closed?
                puts "\033[32;1mArquivo processado com sucesso!"
                return false
            end

            # lê o próximo caractere da entrada
            unless c = @file.getc
                @file.close
                c = "EOF"
            end

            # roda o caractere no dfa
            token = run(c)

            # se o dfa retornou false, aconteceu algo que não devia
            unless token
                puts error(c)
                return false
            end

            # se o dfa retornou um token
            if token.is_a? String
                # volta o cursor, pois o dfa retorna o token só ao receber algo diferente do que esperava
                @file.seek(-1, IO::SEEK_CUR) unless @file.closed?

                # cria o retorno
                tuple = {
                    :lexeme => lexeme,
                    :token  => token,
                    :type   => "-"
                }

                # verifica, se for um id, se ele já tá na tabela e o insere
                if token == "id"
                    lexeme_s = lexeme.to_sym
                    unless @table.has_key? lexeme_s
                        @table[lexeme_s] = tuple
                    else
                        tuple = @table[lexeme_s]
                    end
                end

                return tuple

            # se o dfa não finalizou o processamento e o arquivo foi fechado
            elsif @file.closed?
                # o arquivo foi finalizado antes de encontrar o final de um processamento
                puts error(c)
                return false
            
            # senão, faz a atualização das linhas e preenche o buffer
            else
                if c == "\n"
                    @file_line += 1
                    @file_col = 1
                else
                    @file_col += 1
                end
         
                unless @state == :ini
                    lexeme << c
                end
            end
        end
    end

    def error(c)
        if c == "EOF"
            type = "Fim de arquivo inesperado"
        else
            type = "Caractere inválido"
        end

        erro = "\n\033[31;1mErro [linha: " + String(@file_line) + ", coluna: " + String(@file_col) + 
                "]:\033[0m " + type + " - \"\033[0;1m" + c + "\033[0m\"\nEsperava " + String(@transition[@state].keys.to_s)

        return erro
    end
end