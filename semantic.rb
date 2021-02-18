class Semantic
    attr_accessor :output, :attrs, :lex, :tempCount, :indent

    def initialize(lex)
        # inicializa a string de saída
        @output = {
            "header" => [
                "#include<stdio.h>",
                "typedef char literal[256];",
                "void main(void) {",
            ],
            "tempVars" => [
                "/*----Variaveis temporarias----*/"
            ],
            "vars" => [
                "/*------------------------------*/"
            ],
            "code" => [
            ],
            "end" => [
                "",
                "return 0;",
                "}"
            ]
        }
        @tempCount = 0
        @attrs = []
        @lex = lex
        @indent = 0
    end

    def save(filename)
        unless @lex.noError
            return
        end

        file = File.open(filename + ".c", 'w')
        if file.closed?
            puts "\033[31;1mErro ao abrir o arquivo de saída.\033[0m"
        end

        @output.each do |k, v|
            @output[k].each do |value|
                @indent -= value.count "}"

                file.write(("\t" * @indent) + value)
                file.write("\n")

                @indent += value.count "{"
            end
        end

        file.close
        puts "\033[32;1mGerado " + filename + ".c\033[0m"
    end

    def newTemp(type) 
        @output["tempVars"] << type + " t" + @tempCount.to_s + ";"
        @tempCount += 1
        return "t" + (@tempCount - 1).to_s
    end

    # Regra 5
    def rule5(token, nattrs)
        unless @lex.noError
            return
        end

        @output["vars"] << ""
        @output["vars"] << ""
        @output["vars"] << ""
    end

    # Regra 6
    def rule6(token, nattrs)
        unless @lex.noError
            return
        end

        attrs = @attrs.pop(nattrs)

        attrs[0][:type] = attrs[1][:type]

        @lex.update(attrs[0][:lexeme], attrs[0])

        @output["vars"] << attrs[0][:type] + " " + attrs[0][:lexeme] + ";"
    end

    # Regras 7, 8 e 9
    def rule7_8_9(token, nattrs)
        unless @lex.noError
            return
        end

        attrs = @attrs.pop(nattrs)
        
        @attrs << {
            :lexeme => token,
            :type => attrs[0][:type]
        }
    end

    # Regra 11
    def rule11(token, nattrs)
        unless @lex.noError
            return
        end

        attrs = @attrs.pop(nattrs)

        id = attrs[1]
        if id[:type] == "literal"
            @output["code"] << "scanf(\"%s\", " + id[:lexeme] +  ");"
        elsif id[:type] == "int"
            @output["code"] << "scanf(\"%d\", &" + id[:lexeme] +  ");"
        elsif id[:type] == "double"
            @output["code"] << "scanf(\"%lf\", &" + id[:lexeme] +  ");"
        else
            # TODO implementar rotina de erro
            # não declarado
            @lex.error("sem", id[:lexeme], "UDCL", type="undeclared")
        end
    end

    # Regra 12
    def rule12(token, nattrs)
        unless @lex.noError
            return
        end

        attrs = @attrs.pop(nattrs)

        @output["code"] << "printf(" + attrs[1][:lexeme] + ");"
    end

    # Regra 13
    def rule13(token, nattrs)
        unless @lex.noError
            return
        end

        attrs = @attrs.pop(nattrs)

        @attrs << {
            :lexeme => attrs[0][:lexeme]
        }
    end

    # Regra 14
    def rule14(token, nattrs)
        unless @lex.noError
            return
        end

        attrs = @attrs.pop(nattrs)

        @attrs << {
            :lexeme => "\"%lf\", " + attrs[0][:lexeme]
        }
    end

    # Regra 15
    def rule15(token, nattrs)
        unless @lex.noError
            return
        end

        attrs = @attrs.pop(nattrs)

        id = attrs[0]
        if id[:type] == "literal"
            @attrs << {
                :lexeme => "\"%s\", " + id[:lexeme]
            }
        elsif id[:type] == "int"
            @attrs << {
                :lexeme => "\"%d\", " + id[:lexeme]
            }
        elsif id[:type] == "double"
            @attrs << {
                :lexeme => "\"%lf\", " + id[:lexeme]
            }
        else
            # não declarado
            @lex.error("sem", id[:lexeme], "UDCL", type="undeclared")
        end
    end

    # Regra 17
    def rule17(token, nattrs)
        unless @lex.noError
            return
        end

        attrs = @attrs.pop(nattrs)

        id = attrs[0]
        ld = attrs[2]

        if id[:type] == "-"
            # não declarado
            @lex.error("sem", id[:lexeme], "UDCL", type="undeclared")
        elsif ld[:type] == "-"
            @lex.error("sem", ld[:lexeme], "UDCL", type="undeclared")
        elsif id[:type] == "literal" and ld[:type] == "literal"
            @output["code"] << id[:lexeme] + " = " + ld[:lexeme] + ";"
        elsif id[:type] == "int" and ld[:type] == "int"
            @output["code"] << id[:lexeme] + " = " + ld[:lexeme] + ";"
        elsif id[:type] == "double" and ld[:type] == "double"
            @output["code"] << id[:lexeme] + " = " + ld[:lexeme] + ";"
        else
            # tipos incompativeis
            @lex.error("sem", [id, ld], "ICPT", type="incompatible", "=")
        end        
    end

    # Regra 18
    def rule18(token, nattrs)
        unless @lex.noError
            return
        end

        attrs = @attrs.pop(nattrs)

        oprd1 = attrs[0]
        opm = attrs[1]
        oprd2 = attrs[2]

        if oprd1[:type] == "int" and (oprd2[:type] == "int" or oprd2[:token] == "Num")
            tempVar = newTemp("int")
            @output["code"] << tempVar + " = " + oprd1[:lexeme] + " " + opm[:lexeme] + " " + oprd2[:lexeme] + ";"

            @attrs << {
                :lexeme => tempVar,
                :type => "int"
            }
        elsif oprd1[:type] == "double" and (oprd2[:type] == "double" or oprd2[:token] == "Num")
            tempVar = newTemp("double")
            @output["code"] << tempVar + " = " + oprd1[:lexeme] + " " + opm[:lexeme] + " " + oprd2[:lexeme] + ";"

            @attrs << {
                :lexeme => tempVar,
                :type => "double"
            }
        else
            # tipos incompativeis
            @lex.error("sem", [oprd1, oprd2], "ICPT", type="incompatible", opm[:lexeme])
        end 
    end

    # Regra 19
    def rule19(token, nattrs)
        unless @lex.noError
            return
        end

        attrs = @attrs.pop(nattrs)

        @attrs << attrs[0]
    end

    # Regra 20
    def rule20(token, nattrs)
        unless @lex.noError
            return
        end

        attrs = @attrs.pop(nattrs)

        if attrs[0][:type] == "-"
            # não declarado
            @lex.error("sem", attrs[0][:lexeme], "UDCL", type="undeclared")
        else
            @attrs << attrs[0]
        end
    end

    # Regra 21
    def rule21(token, nattrs)
        unless @lex.noError
            return
        end

        attrs = @attrs.pop(nattrs)

        @attrs << attrs[0]
    end

    def rule23(token, nattrs)
        unless @lex.noError
            return
        end

        @output["code"] << "}"
    end

    def rule24(token, nattrs)
        unless @lex.noError
            return
        end

        attrs = @attrs.pop(nattrs)

        @output["code"] << "if(" + attrs[2][:lexeme] + ") {"
    end

    def rule25(token, nattrs)
        unless @lex.noError
            return
        end

        attrs = @attrs.pop(nattrs)

        oprd1 = attrs[0]
        opr = attrs[1]
        oprd2 = attrs[2]

        if ((oprd1[:type] == "int" or oprd1[:type] == "double") and (oprd2[:type] == "int" or oprd2[:type] == "double")) or (oprd1[:type] == oprd2[:type] and (opr[:lexeme] == "=" or opr[:lexeme] == "<>"))
            tempVar = newTemp("int")

            if opr[:lexeme] == "="
                oprL = "=="
            elsif opr[:lexeme] == "<>"
                oprL = "!="
            else
                oprL = opr[:lexeme]
            end

            @output["code"] << tempVar + " = " + oprd1[:lexeme] + " " + oprL + " " + oprd2[:lexeme] + ";"

            @attrs << {
                :lexeme => tempVar,
                :type => "int"
            }
        else
            # tipos incompativeis
            @lex.error("sem", [oprd1, oprd2], "ICPT", type="incompatible", opr[:lexeme])
        end
    end
end