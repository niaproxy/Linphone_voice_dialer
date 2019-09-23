#/bin/bash
#silence 2 0.1 3% 1 3.0 3%
#silence 1 0.1 5% 1 1.0 5%
#silence 1 0.1 5% 1 2.0 5% norm -1

while true ;do
status=$(linphonecsh status hook)
if [[ $status == "hook=offhook"  ]] ; then
	rec -r 16k -e signed-integer -b 16 -c 1 test.wav silence 1 0.1 3% 1 2.0 3% norm -1 2> /dev/null &
	recpid=$!
	while kill -0 $recpid 2> /dev/null; do
		incoming=$(linphonecsh status hook | awk '{print $1}')
		if [[ $incoming == "Incoming" ]] ; then
			kill -9 $recpid 
			rm test.wav
			#aplay ./digits/start.wav -Dplughw:CARD=Device,DEV=0
			linphonecsh generic answer
fi
sleep 1
done
fi
status=$(linphonecsh status hook)
if [[ $status == "hook=offhook" && -f test.wav ]] ; then
	#rec -r 16k -e signed-integer -b 16 -c 1 test.wav silence 1 0.1 3% 1 2.0 3% norm -1 2> /dev/null
	aplay ./digits/tone.wav -Dplughw:CARD=Device,DEV=0 &
	pocketsphinx_batch -argfile args 2> /dev/null
	string=$(cat ./outname  | sed 's/\( (.*\)//')
	accuracy=$(awk -F - '{print $2}' ~/sphinx/outname| sed 's/)//')
	echo Точность: $accuracy
if [ $accuracy -lt 7100 ]; then
case $string in
*диспетчера)
	echo Вызов диспетчера
	aplay ./digits/disp2.wav -Dplughw:CARD=Device,DEV=0
	#echo "Набираю диспетчера" | festival --language russian --tts
	linphonecsh dial 33242
;;
*набор*)
	i=0 && unset number
	aplay ./digits/call.wav -Dplughw:CARD=Device,DEV=0
for digit in $string; do
let i++

	case $digit in
		ноль)
		number[$i]=0
		aplay ./digits/0.wav -Dplughw:CARD=Device,DEV=0
		;;
		один)
		number[$i]=1
		aplay ./digits/1.wav -Dplughw:CARD=Device,DEV=0
		;;
		два)
		number[$i]=2
		aplay ./digits/2.wav -Dplughw:CARD=Device,DEV=0
		;;
		три)
		number[$i]=3
		aplay ./digits/3.wav -Dplughw:CARD=Device,DEV=0
		;;
		четыре)
		number[$i]=4
		aplay ./digits/4.wav -Dplughw:CARD=Device,DEV=0
		;;
		пять)
		number[$i]=5
		aplay ./digits/5.wav -Dplughw:CARD=Device,DEV=0
		;;
		шесть)
		number[$i]=6 
		aplay ./digits/6.wav -Dplughw:CARD=Device,DEV=0
		;;
		семь)
		number[$i]=7
		aplay ./digits/7.wav -Dplughw:CARD=Device,DEV=0
		;;
		восемь)
		number[$i]=8
		aplay ./digits/8.wav -Dplughw:CARD=Device,DEV=0
		;;
		девять)
		number[$i]=9
		aplay ./digits/9.wav -Dplughw:CARD=Device,DEV=0
		;;
		esac
	done
	godial=$(echo ${number[@]} | sed 's/ //g')
	echo "Набор номера $godial"
	linphonecsh dial $godial

;;

esac
	else
	echo Ошибка
	aplay ./digits/error.wav -Dplughw:CARD=Device,DEV=0
fi
fi
sleep 1

done
