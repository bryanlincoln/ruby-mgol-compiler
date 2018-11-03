require "csv"

class Syntactic
    attr_accessor :transitions, :lex, :grammar

    def initialize(lex)
        # inicializa a tabela de transições
        @transitions = CSV.read("syntax_table.csv", :headers => true)
        @transitions.delete("Table")

        # inicializa a gramática
        @grammar = {
            "1" => {
                "P'" => ["P"] 
            },
            "2" => {
                "P" => ["inicio", "V", "A"],
            },
            "3" => {
                "V" => ["varinicio", "LV"],
            },
            "4" => {
                "LV" => ["D", "LV"],
            },
            "5" => {
                "LV" => ["varfim", ";"],
            },
            "6" => {
                "D" => ["id", "TIPO", ";"],
            },
            "7" => {
                "TIPO" => ["inteiro"],
            },
            "8" => {
                "TIPO" => ["real"],
            },
            "9" => {
                "TIPO" => ["lit"],
            },
            "10" => {
                "A" => ["ES", "A"],
            },
            "11" => {
                "ES" => ["leia", "id", ";"],
            },
            "12" => {
                "ES" => ["escreva", "ARG", ";"],
            },
            "13" => {
                "ARG" => ["literal"],
            },
            "14" => {
                "ARG" => ["num"],
            },
            "15" => {
                "ARG" => ["id"],
            },
            "16" => {
                "A" => ["CMD", "A"],
            },
            "17" => {
                "CMD" => ["id", "rcb", "LD", ";"],
            },
            "18" => {
                "LD" => ["OPRD", "opm", "OPRD"],
            },
            "19" => {
                "LD" => ["OPRD"],
            },
            "20" => {
                "OPRD" => ["id"],
            },
            "21" => {
                "OPRD" => ["num"],
            },
            "22" => {
                "A" => ["COND", "A"],
            },
            "23" => {
                "COND" => ["CABEÇALHO", "CORPO"],
            },
            "24" => {
                "CABEÇALHO" => ["se", "(", "EXP_R", ")", "então"],
            },
            "25" => {
                "EXP_R" => ["OPRD", "opr", "OPRD"],
            },
            "26" => {
                "CORPO" => ["ES", "CORPO"],
            },
            "27" => {
                "CORPO" => ["CMD", "CORPO"],
            },
            "28" => {
                "CORPO" => ["COND", "CORPO"],
            },
            "29" => {
                "CORPO" => ["fimse"],
            },
            "30" => {
                "A" => ["fim"]
            }
        }

        @lex = lex
    end

    def run()
        # chamada do léxico que retorna uma hash {:lexeme, :token, :type}
        tuple = lex.get()
        return unless tuple # erro léxico
        token = tuple[:token]
        stack = ["0"]

        loop do
            state = stack.last.to_i
            
            if @transitions[state][token]
                action = @transitions[state][token][0] 
                args = @transitions[state][token][1..-1].to_i

                if action == "S"
                    stack << args.to_i

                    # chamada do léxico que retorna uma hash {:lexeme, :token, :type}
                    tuple = lex.get()
                    break unless tuple
                    token = tuple[:token]

                elsif action == "R"
                    reduction = @grammar[args.to_s]

                    for i in 0..reduction.values[0].length-1
                        stack.pop
                    end
                    
                    stack << @transitions[stack.last.to_i][reduction.keys[0]]

                    puts reduction.keys[0].to_s + " -> " + reduction.values[0].to_s

                elsif action == "A"
                    return
                else
                    puts "\n\033[31;1mErro [" + state.to_s + token.to_s + "]:\033[0m"
                    return
                end

            else
                puts "\n\033[31;1mErro [" + state.to_s + token.to_s + "]:\033[0m"
                break
            end
        end
    end
end