require "csv"

class Syntactic
    attr_accessor :transitions, :lex, :sem, :grammar

    def initialize(lex, sem)
        # incializa os auxiliares
        @lex = lex
        @sem = sem

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
                "rule" => "rule5"
            },
            "6" => {
                "D" => ["id", "TIPO", ";"],
                "rule" => "rule6"
            },
            "7" => {
                "TIPO" => ["inteiro"],
                "rule" => "rule7_8_9"
            },
            "8" => {
                "TIPO" => ["real"],
                "rule" => "rule7_8_9"
            },
            "9" => {
                "TIPO" => ["lit"],
                "rule" => "rule7_8_9"
            },
            "10" => {
                "A" => ["ES", "A"],
            },
            "11" => {
                "ES" => ["leia", "id", ";"],
                "rule" => "rule11"
            },
            "12" => {
                "ES" => ["escreva", "ARG", ";"],
                "rule" => "rule12"
            },
            "13" => {
                "ARG" => ["literal"],
                "rule" => "rule13"
            },
            "14" => {
                "ARG" => ["num"],
                "rule" => "rule14"
            },
            "15" => {
                "ARG" => ["id"],
                "rule" => "rule15"
            },
            "16" => {
                "A" => ["CMD", "A"],
            },
            "17" => {
                "CMD" => ["id", "rcb", "LD", ";"],
                "rule" => "rule17"
            },
            "18" => {
                "LD" => ["OPRD", "opm", "OPRD"],
                "rule" => "rule18"
            },
            "19" => {
                "LD" => ["OPRD"],
                "rule" => "rule19"
            },
            "20" => {
                "OPRD" => ["id"],
                "rule" => "rule20"
            },
            "21" => {
                "OPRD" => ["num"],
                "rule" => "rule21"
            },
            "22" => {
                "A" => ["COND", "A"],
            },
            "23" => {
                "COND" => ["CABEÇALHO", "CORPO"],
                "rule" => "rule23"
            },
            "24" => {
                "CABEÇALHO" => ["se", "(", "EXP_R", ")", "entao"],
                "rule" => "rule24"
            },
            "25" => {
                "EXP_R" => ["OPRD", "opr", "OPRD"],
                "rule" => "rule25"
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
                    @sem.attrs << tuple

                    # chamada do léxico que retorna uma hash {:lexeme, :token, :type}
                    tuple = lex.get()
                    break unless tuple
                    token = tuple[:token]

                elsif action == "R"
                    reduction = @grammar[args.to_s]

                    for i in 0..reduction.values[0].length-1
                        stack.pop
                    end

                    if reduction.has_key?("rule")
                        @sem.method(reduction["rule"]).call(reduction.keys[0].to_s, reduction.values[0].length)
                    end
                    
                    stack << @transitions[stack.last.to_i][reduction.keys[0]]

                    puts reduction.keys[0].to_s + " -> " + reduction.values[0].to_s

                elsif action == "A"
                    return
                else
                    @lex.error("syn", tuple[:lexeme].to_s, state.to_s + token.to_s, type="unknown")
                    return
                end

            else
                @lex.error("syn", tuple[:lexeme].to_s, state.to_s + token.to_s, type="unexpected")
                break
            end
        end
    end
end