#!/bin/bash
##########################################################################
#questo script crea num rotte di selezionie passante con il numero radice#
#Serve nel caso in cui il modulo DirectDID non può essere usato          #
#                                                                        #
##########################################################################

if [[ $# -eq 0 ]];then
	
        echo "################################### "
	echo "                                   " 
        echo "NON HAI INSERITO NESSUN PARAMETRO"
	echo "                                   " 
	echo "Questo script serve a inserire un massimo di 9 rotte in ingresso, quando non si vuole utilizzare il direct DID presente su Nethvoice."
	echo "E' necessario fornire dei parametri allo script per poter effettuare l'inserimento della rotta in ingresso"
	echo "######"
	echo "######"
	echo "Inserisci come PRIMO parametro la radice della numerazione Pubblica"
	echo "Come SECONDO il numero di rotte"
	echo "Come TERZO parametro le cifre interne da anteporre al secondo parametro"
	echo "                                                                       "
	echo "                                                                       "
        exit 1
fi


if [[ -z $1 ]] ; then
	
	echo "Non hai inserito il primo parametro: Inserisci come primo parametro la radice, come secondo il numero di rotte e infine le 2 cifre interne da anteporre alla radice"
	exit 1

elif [[ -z $2 ]] ; then
        
	echo "Non hai inserito il secondo parametro: Inserisci come primo parametro la radice, come secondo il numero di rotte e infine le 2 cifre interne da anteporre alla radice"
        exit 1

elif  [[ -z $3 ]] ; then

        echo "Non hai inserito il terzo parametro: Inserisci come primo parametro la radice, come secondo il numero di rotte e infine le 2 cifre interne da anteporre alla radice"
        exit 1
else

rad=$1 #numero radice
num=$2 #numero finale

int=$3 #cifre interno da sostituire alla radice e da anteporre al num
max=9

fi

if [[ $num > $max ]] ; then

	echo "###################ERRORE#########################"
	echo "                                                  "
	echo "non è possibile inserire più di 9 rotte per volta"
	exit 1
fi


for i in {0..${num}};do

	mysql -D asterisk -e "insert into incoming (extension,destination,privacyman,alertinfo,ringing,fanswer,mohclass,description,delay_answer,rvolume,indication_zone) values('${rad}${i}','from-did-direct,${int}${i},1','0','<http://www.notused >\;info=ring2','CHECKED','CHECKED','default','selezione passante${i}','0','0','default')"; 

done
