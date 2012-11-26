#!/usr/bin/env bash
# funcoeszz
#
# INFORMAÇÕES: www.funcoeszz.net
# NASCIMENTO : 22 de Fevereiro de 2000
# AUTORES    : Aurelio Marinho Jargas <verde (a) aurelio net>
#              Thobias Salazar Trevisan <thobias (a) thobias org>
# DESCRIÇÃO  : Funções de uso geral para o shell Bash, que buscam
#              informações em arquivos locais e fontes na Internet
# LICENÇA    : GPLv2
# CHANGELOG  : www.funcoeszz.net/changelog.html
#
ZZVERSAO=svn
ZZUTF=1
#
##############################################################################
#
#                                Configuração
#                                ------------
#
#
### Configuração via variáveis de ambiente
#
# Algumas variáveis de ambiente podem ser usadas para alterar o comportamento
# padrão das funções. Basta defini-las em seu .bashrc ou na própria linha de
# comando antes de chamar as funções. São elas:
#
#      $ZZCOR      - Liga/Desliga as mensagens coloridas (1 e 0)
#      $ZZPATH     - Caminho completo para o arquivo principal (funcoeszz)
#      $ZZDIR      - Caminho completo para o diretório com as funções
#      $ZZTMPDIR   - Diretório para armazenar arquivos temporários
#      $ZZOFF      - Lista das funções que você não quer carregar
#
# Nota: Se você é paranóico com segurança, configure a ZZTMPDIR para
#       um diretório dentro do seu HOME.
#
### Configuração fixa neste arquivo (hardcoded)
#
# A configuração também pode ser feita diretamente neste arquivo, se você
# puder fazer alterações nele.
#
ZZCOR_DFT=1                       # colorir mensagens? 1 liga, 0 desliga
ZZPATH_DFT="/usr/bin/funcoeszz"   # rota absoluta deste arquivo
ZZDIR_DFT="$HOME/zz"              # rota absoluta do diretório com as funções
ZZTMPDIR_DFT="${TMPDIR:-/tmp}"    # diretório temporário
#
#
##############################################################################
#
#                               Inicialização
#                               -------------
#
#
# Variáveis auxiliares usadas pelas Funções ZZ.
# Não altere nada aqui.
#
#

ZZWWWDUMP='lynx -dump      -nolist -width=300 -accept_all_cookies -display_charset=UTF-8'
ZZWWWLIST='lynx -dump              -width=300 -accept_all_cookies -display_charset=UTF-8'
ZZWWWPOST='lynx -post-data -nolist -width=300 -accept_all_cookies -display_charset=UTF-8'
ZZWWWHTML='lynx -source'
ZZCODIGOCOR='36;1'            # use zzcores para ver os códigos
ZZSEDURL='s| |+|g;s|&|%26|g;s|@|%40|g'
ZZBASE='zzajuda zztool zzzz'  # Funções essenciais, guardadas neste script


#
### Truques para descobrir a localização deste arquivo no sistema
#
# Se a chamada foi pelo executável, o arquivo é o $0.
# Senão, tenta usar a variável de ambiente ZZPATH, definida pelo usuário.
# Caso não exista, usa o local padrão ZZPATH_DFT.
# Finalmente, força que ZZPATH seja uma rota absoluta.
#
[ "${0##*/}" = 'bash' -o "${0#-}" != "$0" ] || ZZPATH="$0"
[ "$ZZPATH" ] || ZZPATH=$ZZPATH_DFT
[ "${ZZPATH#/}" = "$ZZPATH" ] && ZZPATH="$PWD/${ZZPATH#./}"

[ "$ZZDIR" ] || ZZDIR=$ZZDIR_DFT
#
### Últimos ajustes
#
ZZCOR="${ZZCOR:-$ZZCOR_DFT}"
ZZTMP="${ZZTMPDIR:-$ZZTMPDIR_DFT}"
ZZTMP="${ZZTMP%/}/zz"  # prefixo comum a todos os arquivos temporários
ZZAJUDA="$ZZTMP.ajuda"
unset ZZCOR_DFT ZZPATH_DFT ZZDIR_DFT ZZTMPDIR_DFT
#
#
##############################################################################
#
#                                Ferramentas
#                                -----------
#
#

# ----------------------------------------------------------------------------
# zztool
# Miniferramentas para auxiliar as funções.
# Uso: zztool [-e] ferramenta [argumentos]
# Ex.: zztool grep_var foo $var
#      zztool eco Minha mensagem colorida
#      zztool testa_numero $num
#      zztool -e testa_numero $num || return
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2008-03-01
# ----------------------------------------------------------------------------
zztool ()
{
	local erro ferramenta

	# Devo mostrar a mensagem de erro?
	test "$1" = '-e' && erro=1 && shift

	# Libera o nome da ferramenta do $1
	ferramenta="$1"
	shift

	case "$ferramenta" in
		uso)
			# Extrai a mensagem de uso da função $1, usando seu --help
			zzzz -h "$1" -h | grep Uso
		;;
		eco)
			# Mostra mensagem colorida caso $ZZCOR esteja ligada
			if [ "$ZZCOR" != '1' ]
			then
				echo -e "$*"
			else
				echo -e "\033[${ZZCODIGOCOR}m$*\033[m"
			fi
		;;
		acha)
			# Destaca o padrão $1 no texto via STDIN ou $2
			# O padrão pode ser uma regex no formato BRE (grep/sed)
			local esc=$(printf '\033')
			local padrao=$(echo "$1" | sed 's,/,\\/,g') # escapa /
			shift
			zztool multi_stdin "$@" |
				if [ "$ZZCOR" != '1' ]
				then
					cat -
				else
					sed "s/$padrao/$esc[${ZZCODIGOCOR}m&$esc[m/g"
				fi
		;;
		grep_var)
			# $1 está presente em $2?
			test "${2#*$1}" != "$2"
		;;
		index_var)
			# $1 está em qual posição em $2?
			local padrao="$1"
			local texto="$2"
			if zztool grep_var "$padrao" "$texto"
			then
				texto="${texto%%$padrao*}"
				echo $((${#texto} + 1))
			else
				echo 0
			fi
		;;
		arquivo_vago)
			# Verifica se o nome de arquivo informado está vago
			if test -e "$1"
			then
				echo "Arquivo $1 já existe. Abortando."
				return 1
			fi
		;;
		arquivo_legivel)
			# Verifica se o arquivo existe e é legível
			if ! test -r "$1"
			then
				echo "Não consegui ler o arquivo $1"
				return 1
			fi

			# TODO Usar em *todas* as funções que lêem arquivos
		;;
		num_linhas)
			# Informa o número de linhas, sem formatação
			zztool file_stdin "$@" |
				wc -l |
				tr -d ' \t'
		;;
		testa_ano)
			# Testa se $1 é um ano válido: 1-9999
			# O ano zero nunca existiu, foi de -1 para 1
			# Ano maior que 9999 pesa no processamento
			echo "$1" | grep -v '^00*$' | grep '^[0-9]\{1,4\}$' >/dev/null && return 0

			test -n "$erro" && echo "Ano inválido '$1'"
			return 1
		;;
		testa_ano_bissexto)
			# Testa se $1 é um ano bissexto
			#
			# A year is a leap year if it is evenly divisible by 4
			# ...but not if it's evenly divisible by 100
			# ...unless it's also evenly divisible by 400
			# http://timeanddate.com
			# http://www.delorie.com/gnu/docs/gcal/gcal_34.html
			# http://en.wikipedia.org/wiki/Leap_year
			#
			local y=$1
			[ $((y%4)) -eq 0 ] && [ $((y%100)) -ne 0 ] || [ $((y%400)) -eq 0 ]
			test $? -eq 0 && return 0

			test -n "$erro" && echo "Ano bissexto inválido '$1'"
			return 1
		;;
		testa_numero)
			# Testa se $1 é um número positivo
			echo "$1" | grep '^[0-9]\{1,\}$' >/dev/null && return 0

			test -n "$erro" && echo "Número inválido '$1'"
			return 1

			# TODO Usar em *todas* as funções que recebem números
		;;
		testa_numero_sinal)
			# Testa se $1 é um número (pode ter sinal: -2 +2)
			echo "$1" | grep '^[+-]\{0,1\}[0-9]\{1,\}$' >/dev/null && return 0

			test -n "$erro" && echo "Número inválido '$1'"
			return 1
		;;
		testa_numero_fracionario)
			# Testa se $1 é um número fracionário (1.234 ou 1,234)
			# regex: \d+[,.]\d+
			echo "$1" | grep '^[0-9]\{1,\}[,.][0-9]\{1,\}$' >/dev/null && return 0

			test -n "$erro" && echo "Número inválido '$1'"
			return 1
		;;
		testa_dinheiro)
			# Testa se $1 é um valor monetário (1.234,56 ou 1234,56)
			# regex: (  \d{1,3}(\.\d\d\d)+  |  \d+  ),\d\d
			echo "$1" | grep '^\([0-9]\{1,3\}\(\.[0-9][0-9][0-9]\)\{1,\}\|[0-9]\{1,\}\),[0-9][0-9]$' >/dev/null && return 0

			test -n "$erro" && echo "Valor inválido '$1'"
			return 1
		;;
		testa_binario)
			# Testa se $1 é um número binário
			echo "$1" | grep '^[01]\{1,\}$' >/dev/null && return 0

			test -n "$erro" && echo "Número binário inválido '$1'"
			return 1
		;;
		testa_ip)
			# Testa se $1 é um número IP (nnn.nnn.nnn.nnn)
			local nnn="\([0-9]\{1,2\}\|1[0-9][0-9]\|2[0-4][0-9]\|25[0-5]\)" # 0-255
			echo "$1" | grep "^$nnn\.$nnn\.$nnn\.$nnn$" >/dev/null && return 0

			test -n "$erro" && echo "Número IP inválido '$1'"
			return 1
		;;
		testa_data)
			# Testa se $1 é uma data (dd/mm/aaaa)
			local d29='\(0[1-9]\|[12][0-9]\)/\(0[1-9]\|1[012]\)'
			local d30='30/\(0[13-9]\|1[012]\)'
			local d31='31/\(0[13578]\|1[02]\)'
			echo "$1" | grep "^\($d29\|$d30\|$d31\)/[0-9]\{1,4\}$" >/dev/null && return 0

			test -n "$erro" && echo "Data inválida '$1', deve ser dd/mm/aaaa"
			return 1
		;;
		testa_hora)
			# Testa se $1 é uma hora (hh:mm)
			echo "$1" | grep "^\(0\{0,1\}[0-9]\|1[0-9]\|2[0-3]\):[0-5][0-9]$" >/dev/null && return 0

			test -n "$erro" && echo "Hora inválida '$1'"
			return 1
		;;
		multi_stdin)
			# Mostra na tela os argumentos *ou* a STDIN, nesta ordem
			# Útil para funções/comandos aceitarem dados das duas formas:
			#     echo texto | funcao
			# ou
			#     funcao texto

			if [ "$1" ]
			then
				echo "$*"  # security: always quote to avoid shell expansion
			else
				cat -
			fi
		;;
		file_stdin)
			# Mostra na tela o conteúdo dos arquivos *ou* da STDIN, nesta ordem
			# Útil para funções/comandos aceitarem dados das duas formas:
			#     cat arquivo1 arquivo2 | funcao
			# ou
			#     funcao arquivo1 arquivo2

			cat "${@:--}"  # Traduzindo: cat $@ ou cat -
		;;
		list2lines)
			# Limpa lista da STDIN e retorna um item por linha
			# Lista: um dois três | um, dois, três | um;dois;três
			sed 's/[;,]/ /g' |
				tr -s '\t ' '  ' |
				tr ' ' '\n' |
				grep .
		;;
		lines2list)
			# Recebe linhas em STDIN e retorna: linha1 linha2 linha3
			# Ignora linhas em branco e remove espaços desnecessários
			grep . |
				tr '\n' ' ' |
				sed 's/^ // ; s/ $//'
		;;
		trim)
			zztool multi_stdin "$@" |
				sed 's/^[[:blank:]]*// ; s/[[:blank:]]*$//'
		;;
		endereco_sed)
			# Formata um texto para ser usado como endereço no sed.
			# Números e $ não são alterados, resto fica /entre barras/
			#     foo     -> /foo/
			#     foo/bar -> /foo\/bar/

			local texto="$*"

			if zztool testa_numero "$texto" || test "$texto" = '$'
			then
				echo "$texto"  # 1, 99, $
			else
				echo "$texto" | sed 's:/:\\\/:g ; s:.*:/&/:'
			fi
		;;
		terminal_utf8)
			echo "$LC_ALL $LC_CTYPE $LANG" | grep -i utf >/dev/null
		;;
		texto_em_iso)
			if test $ZZUTF = 1
			then
				iconv -f iso-8859-1 -t utf-8 /dev/stdin
			else
				cat -
			fi
		;;
		texto_em_utf8)
			if test $ZZUTF != 1
			then
				iconv -f utf-8 -t iso-8859-1 /dev/stdin
			else
				cat -
			fi
		;;
		# Ferramentas inexistentes são simplesmente ignoradas
		esac
}


# ----------------------------------------------------------------------------
# zzajuda
# Mostra uma tela de ajuda com explicação e sintaxe de todas as funções.
# Opções: --lista  lista de todas as funções, com sua descrição
#         --uso    resumo de todas as funções, com a sintaxe de uso
# Uso: zzajuda [--lista|--uso]
# Ex.: zzajuda
#      zzajuda --lista
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-05-04
# ----------------------------------------------------------------------------
zzajuda ()
{
	zzzz -h ajuda "$1" && return

	local zzcor_pager

	if test ! -r "$ZZAJUDA"
	then
		echo "Ops! Não encontrei o texto de ajuda em '$ZZAJUDA'." >&2
		echo "Para recriá-lo basta executar o script 'funcoeszz' sem argumentos." >&2
		return
	fi

	case "$1" in
		--uso)
			# Lista com sintaxe de uso, basta pescar as linhas Uso:
			sed -n 's/^Uso: zz/zz/p' "$ZZAJUDA" |
				sort |
				zztool acha '^zz[^ ]*'
		;;
		--lista)
			# Lista de todas as funções no formato: nome descrição
			grep -A2 ^zz "$ZZAJUDA" |
				grep -v ^http |
				sed '
					/^zz/ {
						# Padding: o nome deve ter 15 caracteres
						:pad
						s/^.\{1,14\}$/& /
						t pad

						# Junta a descricao (proxima linha)
						N
						s/\n/ /
					}' |
				grep ^zz |
				sort |
				zztool acha '^zz[^ ]*'
		;;
		*)
			# Desliga cores para os paginadores antigos
			[ "$PAGER" = 'less' -o "$PAGER" = 'more' ] && zzcor_pager=0

			# Mostra a ajuda de todas as funções, paginando
			cat "$ZZAJUDA" |
				ZZCOR=${zzcor_pager:-$ZZCOR} zztool acha 'zz[a-z0-9]\{2,\}' |
				${PAGER:-less -r}
		;;
	esac
}


# ----------------------------------------------------------------------------
# zzzz
# Mostra informações sobre as funções, como versão e localidade.
# Opções: --atualiza  baixa a versão mais nova das funções
#         --teste     testa se a codificação e os pré-requisitos estão OK
#         --bashrc    instala as funções no ~/.bashrc
#         --tcshrc    instala as funções no ~/.tcshrc
#         --zshrc     instala as funções no ~/.zshrc
# Uso: zzzz [--atualiza|--teste|--bashrc|--tcshrc|--zshrc]
# Ex.: zzzz
#      zzzz --teste
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2002-01-07
# ----------------------------------------------------------------------------
zzzz ()
{
	local nome_func arg_func padrao
	local info_instalado info_instalado_zsh info_cor info_utf8 info_base versao_remota
	local arquivo_aliases arquivo_zz
	local n_on n_off
	local bashrc="$HOME/.bashrc"
	local tcshrc="$HOME/.tcshrc"
	local zshrc="$HOME/.zshrc"
	local url_site='http://funcoeszz.net'
	local url_exe="$url_site/funcoeszz"
	local instal_msg='Instalacao das Funcoes ZZ (www.funcoeszz.net)'

	case "$1" in

		# Atenção: Prepare-se para viajar um pouco que é meio complicado :)
		#
		# Todas as funções possuem a opção -h e --help para mostrar um
		# texto rápido de ajuda. Normalmente cada função teria que
		# implementar o código para verificar se recebeu uma destas opções
		# e caso sim, mostrar o texto na tela. Para evitar a repetição de
		# código, estas tarefas estão centralizadas aqui.
		#
		# Chamando a zzzz com a opção -h seguido do nome de uma função e
		# seu primeiro parâmetro recebido, o teste é feito e o texto é
		# mostrado caso necessário.
		#
		# Assim cada função só precisa colocar a seguinte linha no início:
		#
		#     zzzz -h beep "$1" && return
		#
		# Ao ser chamada, a zzzz vai mostrar a ajuda da função zzbeep caso
		# o valor de $1 seja -h ou --help. Se no $1 estiver qualquer outra
		# opção da zzbeep ou argumento, nada acontece.
		#
		# Com o "&& return" no final, a função zzbeep pode sair imediatamente
		# caso a ajuda tenha sido mostrada (retorno zero), ou continuar seu
		# processamento normal caso contrário (retorno um).
		#
		# Se a zzzz -h for chamada sem nenhum outro argumento, é porque o
		# usuário quer ver a ajuda da própria zzzz.
		#
		# Nota: Ao invés de "beep" literal, poderíamos usar $FUNCNAME, mas
		#       o Bash versão 1 não possui essa variável.

		-h | --help)

			nome_func=${2#zz}
			arg_func=$3

			# Nenhum argumento, mostre a ajuda da própria zzzz
			if ! [ "$nome_func" ]
			then
				nome_func='zz'
				arg_func='-h'
			fi

			# Se o usuário informou a opção de ajuda, mostre o texto
			if [ "$arg_func" = '-h' -o "$arg_func" = '--help'  ]
			then
				# Um xunxo bonito: filtra a saída da zzajuda, mostrando
				# apenas a função informada.
				echo
				ZZCOR=0 zzajuda |
					sed -n "/^zz$nome_func$/,/^----*$/ {
						s/^----*$//
						p
					}" |
					zztool acha zz$nome_func
				return 0
			else

				# Alarme falso, o argumento não é nem -h nem --help
				return 1
			fi
		;;

		# Garantia de compatibilidade do -h com o formato antigo (-z):
		# zzzz -z -h zzbeep
		-z)
			zzzz -h "$3" "$2"
		;;

		# Testes de ambiente para garantir o funcionamento das funções
		--teste)

			### Todos os comandos necessários estão instalados?

			local comando tipo_comando comandos_faltando
			local comandos='awk- bc cat chmod- clear- cp cpp- cut diff- du- find- fmt grep iconv- lynx mv od- play- ps- rm sed sleep sort tail- tr uniq'

			for comando in $comandos
			do
				# Este é um comando essencial ou opcional?
				tipo_comando='ESSENCIAL'
				if zztool grep_var - "$comando"
				then
					tipo_comando='opcional'
					comando=${comando%-}
				fi

				printf '%-30s' "Procurando o comando $comando... "

				# Testa se o comando existe
				if type "$comando" >/dev/null 2>&1
				then
					echo 'OK'
				else
					zztool eco "Comando $tipo_comando '$comando' não encontrado"
					comandos_faltando="$comando_faltando $tipo_comando"
				fi
			done

			if [ "$comandos_faltando" ]
			then
				echo
				zztool eco "**Atenção**"
				if zztool grep_var ESSENCIAL "$comandos_faltando"
				then
					echo 'Há pelo menos um comando essencial faltando.'
					echo 'Você precisa instalá-lo para usar as Funções ZZ.'
				else
					echo 'A falta de um comando opcional quebra uma única função.'
					echo 'Talvez você não precise instalá-lo.'
				fi
				echo
			fi

			### Tudo certo com a codificação do sistema e das ZZ?

			local cod_sistema='ISO-8859-1'
			local cod_funcoeszz='ISO-8859-1'

			printf 'Verificando a codificação do sistema... '
			zztool terminal_utf8 && cod_sistema='UTF-8'
			echo "$cod_sistema"

			printf 'Verificando a codificação das Funções ZZ... '
			test $ZZUTF = 1 && cod_funcoeszz='UTF-8'
			echo "$cod_funcoeszz"

			# Se um dia precisar de um teste direto no arquivo:
			# sed 1d "$ZZPATH" | file - | grep UTF-8

			if test "$cod_sistema" != "$cod_funcoeszz"
			then
				# Deixar sem acentuação mesmo, pois eles não vão aparecer
				echo
				zztool eco "**Atencao**"
				echo 'Ha uma incompatibilidade de codificacao.'
				echo "Baixe as Funcoes ZZ versao $cod_sistema."
			fi
		;;

		# Baixa a versão nova, caso diferente da local
		--atualiza)

			echo 'Procurando a versão nova, aguarde.'
			versao_remota=$($ZZWWWDUMP "$url_site/v")
			echo "versão local : $ZZVERSAO"
			echo "versão remota: $versao_remota"
			echo

			# Aborta caso não encontrou a versão nova
			[ "$versao_remota" ] || return

			# Compara e faz o download
			if [ "$ZZVERSAO" != "$versao_remota" ]
			then
				# Vamos baixar a versão ISO-8859-1?
				[ $ZZUTF != '1' ] && url_exe="${url_exe}-iso"

				echo -n 'Baixando a versão nova... '
				$ZZWWWHTML "$url_exe" > "funcoeszz-$versao_remota"
				echo 'PRONTO!'
				echo "Arquivo 'funcoeszz-$versao_remota' baixado, instale-o manualmente."
				echo "O caminho atual é $ZZPATH"
			else
				echo 'Você já está com a versão mais recente.'
			fi
		;;

		# Instala as funções no arquivo .bashrc
		--bashrc)

			if ! grep "^[^#]*${ZZPATH:-zzpath_vazia}" "$bashrc" >/dev/null 2>&1
			then
				# export ZZDIR="$ZZDIR"  # pasta com as funcoes
				cat - >> "$bashrc" <<-EOS

				# $instal_msg
				export ZZOFF=""  # desligue funcoes indesejadas
				export ZZPATH="$ZZPATH"  # script
				source "\$ZZPATH"
				EOS

				echo 'Feito!'
				echo "As Funções ZZ foram instaladas no $bashrc"
			else
				echo "Nada a fazer. As Funções ZZ já estão no $bashrc"
			fi
		;;

		# Cria aliases para as funções no arquivo .tcshrc
		--tcshrc)
			arquivo_aliases="$HOME/.zzcshrc"

			# Chama o arquivo dos aliases no final do .tcshrc
			if ! grep "^[^#]*$arquivo_aliases" "$tcshrc" >/dev/null 2>&1
			then
				# setenv ZZDIR $ZZDIR
				cat - >> "$tcshrc" <<-EOS

				# $instal_msg
				setenv ZZPATH $ZZPATH
				source $arquivo_aliases
				EOS

				echo 'Feito!'
				echo "As Funções ZZ foram instaladas no $tcshrc"
			else
				echo "Nada a fazer. As Funções ZZ já estão no $tcshrc"
			fi

			# Cria o arquivo de aliases
			echo > $arquivo_aliases
			for func in $(ZZCOR=0 zzzz | grep -v '^(' | sed 's/,//g')
			do
				echo "alias zz$func 'funcoeszz zz$func'" >> "$arquivo_aliases"
			done

			# alias para funcoes base
			for func in $(ZZCOR=0 zzzz | grep 'base)' | sed 's/(.*)//; s/,//g')
			do
				echo "alias $func='funcoeszz $func'" >> "$arquivo_aliases"
			done

			echo
			echo "Aliases atualizados no $arquivo_aliases"
		;;

		# Cria aliases para as funções no arquivo .zshrc
		--zshrc)
			arquivo_aliases="$HOME/.zzzshrc"

			# Chama o arquivo dos aliases no final do .zshrc
			if ! grep "^[^#]*$arquivo_aliases" "$zshrc" >/dev/null 2>&1
			then
				# export ZZDIR=$ZZDIR
				cat - >> "$zshrc" <<-EOS

				# $instal_msg
				export ZZPATH=$ZZPATH
				source $arquivo_aliases
				EOS

				echo 'Feito!'
				echo "As Funções ZZ foram instaladas no $zshrc"
			else
				echo "Nada a fazer. As Funções ZZ já estão no $zshrc"
			fi

			# Cria o arquivo de aliases
			echo > $arquivo_aliases
			for func in $(ZZCOR=0 zzzz | grep -v '^(' | sed 's/,//g')
			do
				echo "alias zz$func='funcoeszz zz$func'" >> "$arquivo_aliases"
			done

			# alias para funcoes base
			for func in $(ZZCOR=0 zzzz | grep 'base)' | sed 's/(.*)//; s/,//g')
			do
				echo "alias $func='funcoeszz $func'" >> "$arquivo_aliases"
			done

			echo
			echo "Aliases atualizados no $arquivo_aliases"
		;;

		# Mostra informações sobre as funções
		*)
			# As funções estão configuradas para usar cores?
			[ "$ZZCOR" = '1' ] && info_cor='sim' || info_cor='não'

			# A codificação do arquivo das funções é UTF-8?
			[ "$ZZUTF" = 1 ] && info_utf8='UTF-8' || info_utf8='ISO-8859-1'

			# As funções estão instaladas no bashrc?
			if grep "^[^#]*${ZZPATH:-zzpath_vazia}" "$bashrc" >/dev/null 2>&1
			then
				info_instalado="$bashrc"
			else
				info_instalado='não instalado'
			fi

			# As funções estão instaladas no zshrc?
			if grep "^[^#]*${ZZPATH:-zzpath_vazia}" "$zshrc" >/dev/null 2>&1
			then
				info_instalado_zsh="$zshrc"
			else
				info_instalado_zsh='não instalado'
			fi

			# Formata funções essenciais
			info_base=$(echo $ZZBASE | sed 's/ /, /g')

			# Informações, uma por linha
			zztool acha '^[^)]*)' "(script) $ZZPATH"
			zztool acha '^[^)]*)' "( pasta) $ZZDIR"
			zztool acha '^[^)]*)' "(versão) $ZZVERSAO ($info_utf8)"
			zztool acha '^[^)]*)' "( cores) $info_cor"
			zztool acha '^[^)]*)' "(   tmp) $ZZTMP"
			zztool acha '^[^)]*)' "(bashrc) $info_instalado"
			zztool acha '^[^)]*)' "( zshrc) $info_instalado_zsh"
			zztool acha '^[^)]*)' "(  base) $info_base"
			zztool acha '^[^)]*)' "(  site) $url_site"

			# Lista de todas as funções

			# Sem $ZZDIR, provavelmente usando --tudo-em-um
			# Tentarei obter a lista de funções carregadas na shell atual
			if test -z "$ZZDIR"
			then
				set |
					sed -n '/^zz[a-z0-9]/ s/ *().*//p' |
					egrep -v "$(echo $ZZBASE | sed 's/ /|/g')" |
					sort > "$ZZTMP.on"
			fi

			if test -r "$ZZTMP.on"
			then
				echo
				n_on=$(zztool num_linhas "$ZZTMP.on")
				zztool eco "(( $n_on funções disponíveis ))"
				cat "$ZZTMP.on" |
					sed 's/^zz//' |
					zztool lines2list |
					sed 's/ /, /g' |
					fmt -w 70
			else
				echo
				echo "Não consegui obter a lista de funções disponíveis."
				echo "Para recriá-la basta executar o script 'funcoeszz' sem argumentos."
			fi

			# Só mostra se encontrar o arquivo...
			if test -r "$ZZTMP.off"
			then
				# ...e se ele tiver ao menos uma zz
				grep zz "$ZZTMP.off" >/dev/null || return

				echo
				n_off=$(zztool num_linhas "$ZZTMP.off")
				zztool eco "(( $n_off funções desativadas ))"
				cat "$ZZTMP.off" |
					sed 's/^zz//' |
					zztool lines2list |
					sed 's/ /, /g' |
					fmt -w 70
			else
				echo
				echo "Não consegui obter a lista de funções desativadas."
				echo "Para recriá-la basta executar o script 'funcoeszz' sem argumentos."
			fi
		;;
	esac
}

# A linha seguinte é usada pela opção --tudo-em-um
#@
# ----------------------------------------------------------------------------
# zzdicbabelfish
# http://babelfish.altavista.digital.com
# Faz traduções de palavras/frases/textos entre idiomas.
# Basta especificar quais os idiomas de origem e destino e a frase.
# Obs.: Se os idiomas forem omitidos, a tradução será inglês -> português.
#
# Idiomas: pt_en pt_fr es_en es_fr it_en it_fr de_en de_fr
#          fr_en fr_de fr_el fr_it fr_pt fr_nl fr_es
#          ja_en ko_en zh_en zt_en el_en el_fr nl_en nl_fr ru_en
#          en_zh en_zt en_nl en_fr en_de en_el en_it en_ja
#          en_ko en_pt en_ru en_es
#
# Uso: zzdicbabelfish [idiomas] palavra(s)
# Ex.: zzdicbabelfish my dog is green
#      zzdicbabelfish pt_en falcão é massa
#      zzdicbabelfish en_de my hovercraft if full of eels
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Licença: GPL
# ----------------------------------------------------------------------------
zzdicbabelfish ()
{
	zzzz -h dicbabelfish "$1" && return

	local padrao
	local url='http://babelfish.yahoo.com/translate_txt'
	local extra='ei=UTF-8&eo=UTF-8&doit=done&fr=bf-home&intl=1&tt=urltext'
	local lang=en_pt

	# Verificação dos parâmetros
	[ "$1" ] || { zztool uso dicbabelfish; return 1; }

	if [ "${1#[a-z][a-z]_[a-z][a-z]}" = '' ]
	then
		lang=$1
		shift
	elif [ "$1" = 'i' ]
	then
		lang=pt_en
		shift
	fi

	padrao=$(echo "$*" | sed "$ZZSEDURL")
	$ZZWWWHTML "$url?$extra&trtext=$padrao&lp=$lang" |
		sed -n '
			/<div id="result">/ {
				s/<[^>]*>//g
				s/^ *//p
			}'
}

# ----------------------------------------------------------------------------
# zzdicbabylon
# http://www.babylon.com
# Tradução de UMA PALAVRA em inglês para vários idiomas.
# Francês, alemão, japonês, italiano, hebreu, espanhol, holandês e português.
# Se nenhum idioma for informado, o padrão é o português.
# Uso: zzdicbabylon [idioma] palavra   #idioma:dut fre ger heb ita jap ptg spa
# Ex.: zzdicbabylon hardcore
#      zzdicbabylon jap tree
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Licença: GPL
# ----------------------------------------------------------------------------
zzdicbabylon ()
{
	zzzz -h dicbabylon "$1" && return

	local idioma='ptg'
	local idiomas=' dut fre ger heb ita jap ptg spa '
	local tab=$(echo -e \\t)

	# Verificação dos parâmetros
	[ "$1" ] || { zztool uso dicbabylon; return 1; }

	# O primeiro argumento é um idioma?
	if [ "${idiomas% $1 *}" != "$idiomas" ]
	then
		idioma=$1
		shift
	fi

	$ZZWWWHTML "http://online.babylon.com/cgi-bin/trans.cgi?lang=$idioma&word=$1" |
		sed "
			/OT_CopyrightStyle/,$ d
			/definition/,/<\/div>/!d
			/GA_google/d
			s/^[$tab ]*//
			s/<[^>]*>//g
			/^$/d
			N;s/\n/ /
			s/      / /
			" |
		zztool texto_em_utf8
}

# ----------------------------------------------------------------------------
# zzdicportugues
# http://www.dicio.com.br
# Dicionário de português.
# Uso: zzdicportugues palavra
# Ex.: zzdicportugues bolacha
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2003-02-26
# Licença: GPL
# ----------------------------------------------------------------------------
zzdicportugues ()
{
	zzzz -h dicportugues "$1" && return

	local url='http://dicio.com.br/pesquisa.php'
	local ini='^Significado de '
	local fim='^Definição de '
	local padrao=$(echo $* | sed "$ZZSEDURL")

	# TODO XXX Não consegui fazer funcionar com palavras acentuadas :(
	# O site é iso-8859-1.
	# padrao="maçã"
	# padrao=$(echo maçã | iconv -f utf-8 -t iso-8859-1)
	# padrao='ma&ccedil;&agrave;'
	# padrao='ma%E7%E3'
	# ZZWWWDUMP='lynx -dump -nolist -width=300 -accept_all_cookies -assume_unrec_charset=iso-8859-1'

	# Verificação dos parâmetros
	[ "$1" ] || { zztool uso dicportugues; return 1; }

	$ZZWWWDUMP "$url?q=$padrao" |
		sed -n "
			/$ini/,/$fim/ {
				/$ini/d
				/$fim/d
				s/^ *//
				p
			}"
}

# ----------------------------------------------------------------------------
# zzdicportugues2
# http://www.dicio.com.br
# Dicionário de português.
# Definição de palavras e conjugação verbal
# Fornecendo uma "palavra" como argumento retorna seu significado e sinônimo.
# Se for seguida do termo "def", retorna suas definições.
# Se for seguida do termo "conj", retorna todas as formas de conjugação.
# Pode-se filtrar pelos modos de conjugação, fornecendo após o "conj" o modo
# desejado:
# ind (indicativo), sub (subjuntivo), imp (imperativo), inf (infinitivo)
#
# Uso: zzdicportugues2 palavra [def|conj [ind|sub|conj|imp|inf]]
# Ex.: zzdicportugues2 bolacha
#      zzdicportugues2 verbo conj sub
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net - modicado por Itamar
# Desde: 2011-04-16
# Versão: 4
# Licença: GPL
# Requisitos: zzsemacento zzminusculas
# ----------------------------------------------------------------------------
zzdicportugues2 ()
{
	zzzz -h dicportugues2 "$1" && return

	local url='http://dicio.com.br'
	local ini='^Significado de '
	local fim='^Definição de '
	local palavra=$(echo "$1"| zzminusculas)
	local padrao=$(echo "$palavra" | zzsemacento)
	local contador=1
	local resultado

	# Verificação dos parâmetros
	[ "$1" ] || { zztool uso dicportugues2; return 1; }

	# Verificando se a palavra confere na pesquisa
	until [ "$resultado" = "$palavra" ]
	do
		resultado=$(
		$ZZWWWDUMP "$url/$padrao" |
			sed -n "
			/$ini/{
				s/$ini//
				s/ *$//
				p
				}" |
			zzminusculas
			)
		[ "$resultado" ] || { zztool eco "Palavra não encontrada"; return 1; }

		# Incrementando o contador no padrão
		padrao=$(echo "$padrao"|sed 's/_[0-9]*$//')
		let contador++
		padrao=${padrao}_${contador}
	done

	# Restabelecendo o contador
	padrao=$(echo "$padrao"|sed 's/_[0-9]*$//')
	let contador--
	padrao=$(echo "${padrao}_${contador}"|sed 's/_1$//')

	case "$2" in
	def) ini='^Definição de '; fim=' escrita ao contrário: ' ;;
	conj)
		ini='Infinitivo:'; fim='\(Rimas com \|Anagramas de \)'
		case "$3" in
			ind) ini=' *\(INDICATIVO\|Indicativo\)'; fim='^ *\(SUBJUNTIVO\|Subjuntivo\)' ;;
			sub|conj) ini='^ *\(SUBJUNTIVO\|Subjuntivo\)'; fim='^ *\(IMPERATIVO\|Imperativo\)' ;;
			imp) ini='^ *\(IMPERATIVO\|Imperativo\)'; fim='^ *\(INFINITIVO\|Infinitivo\)' ;;
			inf) ini='^ *\(INFINITIVO\|Infinitivo\) *$' ;;
		esac
	;;
	esac

	case "$2" in
	conj)
		$ZZWWWDUMP "$url/$padrao" |
			sed -n "
			/$ini/,/$fim/ {
				/^ *\(INDICATIVO\|Indicativo\) *$/d
				/^ *\(SUBJUNTIVO\|Subjuntivo\) *$/d
				#/^ *\(CONJUNTIVO\|Conjuntivo\) *$/d
				/^ *\(IMPERATIVO\|Imperativo\) *$/d
				/^ *\(INFINITIVO\|Infinitivo\) *$/d
				/\(Rimas com \|Anagramas de \)/d
				/^ *$/d
				s/^ *//
				s/^\*/\n&/
				#s/ do \(Indicativo\|Subjuntivo\|Conjuntivo\)/&\n/
				#s/\* Imperativo \(Afirmativo\|Negativo\)/&\n/
				#s/\* Imperativo/&\n/
				#s/\* Infinitivo Pessoal/&\n/
				s/^[a-z]/ &/g
				p
				}"
	;;
	*)
		$ZZWWWDUMP "$url/$padrao" |
			sed -n "
			/$ini/,/$fim/ {
				/$ini/d
				/^Definição de /d
				p
				}
			/Infinitivo:/,/Particípio passado:/p"
	;;
	esac
}

# ----------------------------------------------------------------------------
# zzdictodos
# Usa todas as funções de dicionário e tradução de uma vez.
# Uso: zzdictodos palavra
# Ex.: zzdictodos Linux
#
# Autor: Aurelio Marinho Jargas, www.aurelio.net
# Desde: 2000-02-22
# Licença: GPL
# Requisitos: zzdicbabelfish zzdicbabylon zzdicjargon zzdicportugues
# ----------------------------------------------------------------------------
zzdictodos ()
{
	zzzz -h dictodos "$1" && return

	local dic

	# Verificação dos parâmetros
	[ "$1" ] || { zztool uso dictodos; return 1; }

	for dic in babelfish babylon jargon portugues
	do
		zztool eco "zzdic$dic:"
		zzdic$dic $1
	done
}

# ----------------------------------------------------------------------------
# zztradutor
# http://translate.google.com
# Google Tradutor, para traduzir frases para vários idiomas.
# Caso não especificado o idioma, a tradução será português -> inglês.
# Use a opção -l ou --lista para ver todos os idiomas disponíveis.
# Use a opção -a ou --audio para ouvir a frase na voz feminina do google.
#
# Alguns idiomas populares são:
#      pt = português         fr = francês
#      en = inglês            it = italiano
#      es = espanhol          de = alemão
#
# Uso: zztradutor [de-para] palavras
# Ex.: zztradutor o livro está na mesa    # the book is on the table
#      zztradutor pt-en livro             # book
#      zztradutor pt-es livro             # libro
#      zztradutor pt-de livro             # Buch
#      zztradutor de-pt Buch              # livro
#      zztradutor de-es Buch              # Libro
#      zztradutor --lista                 # Lista todos os idiomas
#      zztradutor --lista eslo            # Procura por "eslo" nos idiomas
#      zztradutor --audio                 # Gera um arquivo OUT.WAV
#
# Autor: Marcell S. Martini <marcellmartini (a) gmail com>
# Desde: 2008-09-02
# Versão: 5
# Licença: GPLv2
# Requisitos: iconv
# ----------------------------------------------------------------------------
zztradutor ()
{
	zzzz -h tradutor "$1" && return

	[ "$1" ] || { zztool uso tradutor; return 1; }

	# Variaveis locais
	local padrao
	local url='http://translate.google.com.br'
	local lang_de='pt'
	local lang_para='en'
	local charset_de='ISO-8859-1'
	local charset_para='UTF-8'
	local audio_file="/tmp/$$.WAV"
	local play_cmd='mpg123 -q'

	case "$1" in
		# O usuário informou um par de idiomas, como pt-en
		[a-z][a-z]-[a-z][a-z])
			lang_de=${1%-??}
			lang_para=${1#??-}
			shift
		;;
		-l | --lista)
			# Uma tag por linha, então extrai e formata as opções do <SELECT>
			$ZZWWWHTML "$url" |
			sed 's/</\n&/g'  |
			sed -n '/<option value=af>/,/<option value=yi>/p' |
			sed -n '1p;2,/value=af/p' | sed -n '$d;1~2p' |
			sed 's/<option .*value=/ /g;s/>/: /g;s/zh-CN/cn/g'|
			iconv -f $charset_de -t $charset_para |
			grep ${2:-:}
			return
		;;
		-a | --audio)
			# Narrativa
				shift
				padrao=$(echo "$*" | sed "$ZZSEDURL")
				local audio="translate_tts?ie=$charset_para&q=$padrao&tl=pt&prev=input"
				$ZZWWWHTML "$url/$audio" > $audio_file && $play_cmd $audio_file && rm -rf $audio_file
				return
		;;
	esac

	padrao=$(echo "$*" | sed "$ZZSEDURL")

	# Exceção para o chinês, que usa um código diferente
	test $lang_para = 'cn' && lang_para='zh-CN'

	# Baixa a URL, coloca cada tag em uma linha, pega a linha desejada
	# e limpa essa linha para estar somente o texto desejado.
	$ZZWWWHTML "$url?tr=$lang_de&hl=$lang_para&text=$padrao" |
		iconv --from-code=$charset_de --to-code=$charset_para |
		awk 'gsub("<[^/]", "\n&")' |
		grep '<span title' |
		sed 's/<[^>]*>//g'
}


ZZDIR=

##############################################################################
#
#                             Texto de ajuda
#                             --------------
#
#

# Função temporária para extrair o texto de ajuda do cabeçalho das funções
# Passe o arquivo com as funções como parâmetro
_extrai_ajuda() {
	# Extrai somente os cabeçalhos, já removendo o # do início
	sed -n '/^# -----* *$/, /^# -----* *$/ s/^# \{0,1\}//p' "$1" |
		# Agora remove trechos que não podem aparecer na ajuda
		sed '
			# Apaga a metadata (Autor, Desde, Versao, etc)
			/^Autor:/, /^------/ d

			# Apaga a linha em branco apos Ex.:
			/^Ex\.:/, /^------/ {
				/^ *$/d
			}'
}

# Limpa conteúdo do arquivo de ajuda
> "$ZZAJUDA"

# Salva o texto de ajuda das funções deste arquivo
test -r "$ZZPATH" && _extrai_ajuda "$ZZPATH" >> "$ZZAJUDA"


##############################################################################
#
#                    Carregamento das funções do $ZZDIR
#                    ----------------------------------
#
# O carregamento é feito em dois passos para ficar mais robusto:
# 1. Obtenção da lista completa de funções, ativadas e desativadas.
# 2. Carga de cada função ativada, salvando o texto de ajuda.
#
# Com a opção --tudo-em-um, o passo 2 é alterado para mostrar o conteúdo
# da função em vez de carregá-la.
#

### Passo 1

# Limpa arquivos temporários que guardam as listagens
> "$ZZTMP.on"
> "$ZZTMP.off"

# A pasta das funções existe?
if test -n "$ZZDIR" -a -d "$ZZDIR"
then
	# Melhora a lista off: um por linha, sem prefixo zz
	zz_off=$(echo "$ZZOFF" | zztool list2lines | sed 's/^zz//')

	# Primeiro salva a lista de funções disponíveis
	for zz_arquivo in "${ZZDIR%/}"/zz*
	do
		# Só ativa funções que podem ser lidas
		if test -r "$zz_arquivo"
		then
			zz_nome="${zz_arquivo##*/}"  # remove path

			# O usuário desativou esta função?
			echo "$zz_off" | grep "^${zz_nome#zz}$" >/dev/null ||
				# Tudo certo, essa vai ser carregada
				echo "$zz_nome"
		fi
	done >> "$ZZTMP.on"

	# Lista das funções desativadas (OFF = Todas - ON)
	(
	cd "$ZZDIR" &&
	ls -1 zz* |
		grep -v -f "$ZZTMP.on"
	) >> "$ZZTMP.off"
fi

# echo ON ; cat "$ZZTMP.on"  | zztool lines2list
# echo OFF; cat "$ZZTMP.off" | zztool lines2list
# exit

### Passo 2

# Vamos juntar todas as funções em um único arquivo?
if test "$1" = '--tudo-em-um'
then
	# Verifica se a pasta das funções existe
	if test -z "$ZZDIR" -o ! -d "$ZZDIR"
	then
		(
		echo "Ops! Não encontrei as funções na pasta '$ZZDIR'."
		echo 'Informe a localização correta na variável $ZZDIR.'
		echo
		echo 'Exemplo: export ZZDIR="$HOME/zz"'
		) >&2
		exit 1
		# Posso usar exit porque a chamada é pelo executável, e não source
	fi

	# Primeira metade deste arquivo, até #@
	sed '/^#@$/q' "$ZZPATH"

	# Mostra cada função (ativa), inserindo seu nome na linha 2 do cabeçalho
	while read zz_nome
	do
		zz_arquivo="${ZZDIR%/}"/$zz_nome

		sed 1q "$zz_arquivo"
		echo "# $zz_nome"
		sed 1d "$zz_arquivo"

		# Linha em branco separadora
		# Também garante quebra se faltar \n na última linha da função
		echo
	done < "$ZZTMP.on"

	# Desliga suporte ao diretório de funções
	echo
	echo 'ZZDIR='

	# Segunda metade deste arquivo, depois de #@
	sed '1,/^#@$/d' "$ZZPATH"

	# Tá feito, simbora.
	exit 0
fi

# Carregamento das funções ativas, salvando texto de ajuda
while read zz_nome
do
	zz_arquivo="${ZZDIR%/}"/$zz_nome

	# Inclui a função na shell atual
	source "$zz_arquivo"

	# Extrai o texto de ajuda
	_extrai_ajuda "$zz_arquivo" |
		# Insere o nome da função na segunda linha
		sed "2 { h; s/.*/$zz_nome/; G; }"

done < "$ZZTMP.on" >> "$ZZAJUDA"

# Separador final do arquivo, com exatamente 77 hífens (7x11)
echo '-------' | sed 's/.*/&&&&&&&&&&&/' >> "$ZZAJUDA"


# Modo --tudo-em-um
# Todas as funções já foram carregadas por estarem dentro deste arquivo.
# Agora faremos o desligamento "manual" das funções ZZOFF.
#
if test -z "$ZZDIR" -a -n "$ZZOFF"
then

	# Lista de funções a desligar: uma por linha, com prefixo zz, exceto ZZBASE
	zz_off=$(
		echo "$ZZOFF" |
		zztool list2lines |
		sed 's/^zz// ; s/^/zz/' |
		egrep -v "$(echo $ZZBASE | sed 's/ /|/g')"
	)

	# Desliga todas em uma só linha (note que não usei aspas)
	unset $zz_off

	# Agora apaga os textos da ajuda, montando um script em sed e aplicando
	# Veja issue 5 para mais detalhes.
	zz_sed=$(echo "$zz_off" | sed 's@.*@/^&$/,/^----*$/d;@')  # /^zzfoo$/,/^----*$/d
	cp "$ZZAJUDA" "$ZZAJUDA.2" &&
	sed "$zz_sed" "$ZZAJUDA.2" > "$ZZAJUDA"
	rm "$ZZAJUDA.2"
fi


### Carregamento terminado, funções já estão disponíveis

# Limpa variáveis e funções temporárias
# Nota: prefixo zz_ para não conflitar com variáveis da shell atual
unset zz_arquivo
unset zz_nome
unset zz_off
unset zz_sed
unset _extrai_ajuda


##----------------------------------------------------------------------------
## Lidando com a chamada pelo executável

# Se há parâmetros, é porque o usuário está nos chamando pela
# linha de comando, e não pelo comando source.
if [ "$1" ]
then

	case "$1" in

		# Mostra a tela de ajuda
		-h | --help)

			cat - <<-FIM

				Uso: funcoeszz <função> [<parâmetros>]

				Lista de funções:
				    funcoeszz zzzz
				    funcoeszz zzajuda --lista

				Ajuda:
				    funcoeszz zzajuda
				    funcoeszz zzcores -h
				    funcoeszz zzcalcula -h

				Instalação:
				    funcoeszz zzzz --bashrc
				    source ~/.bashrc
				    zz<TAB><TAB>

				Saiba mais:
				    http://funcoeszz.net

			FIM
		;;

		# Mostra a versão das funções
		-v | --version)
			echo "Funções ZZ v$ZZVERSAO"
		;;

		-*)
			echo "Opção inválida '$1' (tente --help)"
		;;

		# Chama a função informada em $1, caso ela exista
		*)
			func="$1"

			# Garante que a zzzz possa ser chamada por zz somente
			[ "$func" = 'zz' ] && func='zzzz'

			# O prefixo zz é opcional: zzdata e data funcionam
			func="zz${func#zz}"

			# A função existe?
			if type $func >/dev/null 2>&1
			then
				shift
				$func "$@"
			else
				echo "Função inexistente '$func' (tente --help)"
			fi
		;;
	esac
fi

# Arquivo gerado em 2012-10-11 as 19:18:14 por Funcoes ZZ a la carte
# http://funcoeszz.net/a-la-carte/?zz=dicbabelfish,dicbabylon,dicportugues,dicportugues2,dictodos,tradutor
