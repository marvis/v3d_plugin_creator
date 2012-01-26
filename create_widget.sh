#! /bin/sh
if [ "$#" = "0" ]
then 
	echo "usage: create_code_v3d_widget.sh <DialogTemplate> [<OutputFile>]"
	echo ""
	echo "EXAMPLE : WidgetTemplate"
	echo "#############################################################"
	echo 'CLASS QDialog TestDialog'
	echo ''
	echo 'D QLabel label_subject "Subject Image :"'
	echo 'D QComboBox combo_subject | addItems(items)'
	echo ''
	echo 'D QLabel label_target "Target Image :"'
	echo 'D QComboBox combo_target | addItems(items)'
	echo ''
	echo 'D QLabel label_sub_channel "Subject Channel :"'
	echo 'D QLabel label_tar_channel "Target Channel :"'
	echo ''
	echo 'D QSpinBox channel_sub | setMaximum(3) setValue(0)'
	echo 'D QSpinBox channel_tar | setMaximum(3) setValue(0)'
	echo ''
	echo 'D QPushButton ok "ok"'
	echo 'D QPushButton cancel "cancel"'
	echo ''
	echo 'D QGridLayout gridLayout'
	echo 'L 0 0 label_subject'
	echo 'L 0 1 combo_subject 1 5'
	echo 'L 1 0 label_sub_channel'
	echo 'L 1 1 channel_sub 1 1'
	echo 'L 2 0 label_target'
	echo 'L 2 1 combo_target 1 5'
	echo 'L 3 0 label_tar_channel'
	echo 'L 3 1 channel_tar'
	echo 'L 5 4 cancel Qt::AlignRight'
	echo 'L 5 5 ok     Qt::AlignRight'
	echo ''
	echo 'C ok clicked() this accept()'
	echo 'C cancel clicked() this reject()'
	echo ''
	echo 'C combo_subject currentIndexChanged(int) this update()'
	echo 'C combo_target currentIndexChanged(int) this update()'
	echo ''
	echo 'C channel_sub valueChanged(int) this update()'
	echo 'C channel_tar valueChanged(int) this update()'
	echo ''
	echo 'R this | setLayout(gridLayout)'
	echo 'R this | setWindowTitle("Test Widget")'
	echo ''
	echo 'U int i1 | combo_subject->currentIndex()'
	echo 'U int i2 | combo_target->currentIndex()'
	echo 'U int c1 | channel_sub->text().toInt()'
	echo 'U int c2 | channel_tar->text().toInt()'
	echo '================================================='
	echo 'CLASS QWidget TestWidget'
	echo ''
	echo 'D QLabel label_subject "Subject Image :"'
	echo 'D QComboBox combo_subject '
	echo ''
	echo 'D QLabel label_target "Target Image :"'
	echo 'D QComboBox combo_target '
	echo ''
	echo 'D QLabel label_sub_channel "Subject Channel :"'
	echo 'D QLabel label_tar_channel "Target Channel :"'
	echo ''
	echo 'D QSpinBox channel_sub'
	echo 'D QSpinBox channel_tar'
	echo ''
	echo 'D QPushButton ok "ok"'
	echo 'D QPushButton cancel "cancel"'
	echo ''
	echo 'D QVBoxLayout gridLayout'
	echo ''
	echo 'L 0 0 label_subject'
	echo 'L 0 1 combo_subject 1 5'
	echo 'L 1 0 label_sub_channel'
	echo 'L 1 1 channel_sub 1 1'
	echo 'L 2 0 label_target'
	echo 'L 2 1 combo_target 1 5'
	echo 'L 3 0 label_tar_channel'
	echo 'L 3 1 channel_tar'
	echo 'L 5 4 cancel Qt::AlignRight'
	echo 'L 5 5 ok     Qt::AlignRight'
	echo ''
	echo 'C ok clicked() this accept()'
	echo 'C cancel clicked() this reject()'
	echo ''
	echo 'C combo_subject currentIndexChanged(int) this onSubjectChanged()'
	echo 'C combo_target currentIndexChanged(int) this onTargetChanged()'
	echo ''
	echo 'C channel_sub valueChanged(int) this onChannelChanged()'
	echo 'C channel_tar valueChanged(int) this onChannelChanged()'
	echo "#############################################################"
	exit 1
fi

TEMPLATE=$1
OUTPUT_FILE=$2

CLASS_NAME=""
STAT=""
DEFINITIONS=""
UPDATE_DEFS=""
UPDATE_CODES=""
SLOT_FUNCS=()

if [ "$OUTPUT_FILE" = "" ]; then
	OUTPUT_FILE=`basename $TEMPLATE .tmpl`.h
fi
echo "create $OUTPUT_FILE ..."

if [ 1 ]; then

	echo "#ifndef __`echo $OUTPUT_FILE | tr '.' '_' | tr [:lower:] [:upper:] `__"
	echo "#define __`echo $OUTPUT_FILE | tr '.' '_' | tr [:lower:] [:upper:] `__"
	echo ""
	echo "#include <QtGui>"
	echo "#include <v3d_interface.h>"
	echo ""

	while read line
	do
		if [ "$line" = "" ]
		then
			echo ""
			if [ "$STAT" = "D" ]
			then
				DEFINITIONS="${DEFINITIONS}\n"
			elif [ "$STAT" = "U" ]
			then
				UPDATE_DEFS="${UPDATE_DEFS}\n"
				UPDATE_CODES="${UPDATE_CODES}\n"
			fi
			continue
		fi

		TYPE=`echo $line | awk '{print $1}'`
		if [ "$TYPE" = "CLASS" ]
		then
			if [ "$CLASS_NAME" = "" ]
			then
				CLASS_TYPE=`echo $line | awk '{print $2}'`
				CLASS_NAME=`echo $line | awk '{print $3}'`
				echo "class $CLASS_NAME : public $CLASS_TYPE"
				echo "{"
				echo -e "\tQ_OBJECT"
				echo ""
				echo "public:"
				echo -e "\t$CLASS_NAME(V3DPluginCallback2 &callback, QWidget * parent) : $CLASS_TYPE(parent)"
				echo -e "\t{"
				echo -e "\t\tthis->callback = &callback;"
				echo -e "\t\tcurwin = callback.currentImageWindow();"
				echo ""
				echo -e "\t\tv3dhandleList win_list = callback.getImageWindowList();"
				echo -e "\t\tQStringList items;"
				echo -e "\t\tfor(int i = 0; i < win_list.size(); i++) items << callback.getImageName(win_list[i]);"
			else
				echo -e "\t}"
				echo ""
				echo -e "\t~$CLASS_NAME(){}"
				echo ""
				echo "public slots:"
				i=0
				while [ "$i" -lt ${#SLOT_FUNCS[@]} ]
				do
					if [ "${SLOT_FUNCS[$i]}" != "update()" ]; then
						echo -e "\tvoid ${SLOT_FUNCS[$i]}"
						echo -e "\t{"
						echo -e "\t}"
					else
						echo -e "\tvoid update()"
						echo -e "\t{"
						echo -e "$UPDATE_CODES"
						echo -e "\t}"
					fi
					i=$[i+1]
					echo ""
				done
				echo "public:"
				echo -ne "$UPDATE_DEFS"
				echo -ne "$DEFINITIONS"
				echo -e "\tV3DPluginCallback2 * callback;"
				echo -e "\tv3dhandle curwin;"
				echo "};"
				echo ""
				echo ""

				CLASS_TYPE=`echo $line | awk '{print $2}'`
				CLASS_NAME=`echo $line | awk '{print $3}'`
				DEFINITIONS=""
				UPDATE_DEFS=""
				UPDATE_CODES=""
				STAT=""
				SLOT_FUNCS=()
				echo "class $CLASS_NAME : public $CLASS_TYPE"
				echo "{"
				echo -e "\tQ_OBJECT"
				echo ""
				echo "public:"
				echo -e "\t$CLASS_NAME(V3DPluginCallback2 &callback, QWidget * parent) : QWidget(parent)"
				echo -e "\t{"
				echo -e "\t\tthis->callback = &callback;"
				echo -e "\t\tcurwin = callback.currentImageWindow();"
				echo ""
				echo -e "\t\tv3dhandleList win_list = callback.getImageWindowList();"
				echo -e "\t\tQStringList items;"
				echo -e "\t\tfor(int i = 0; i < win_list.size(); i++) items << callback.getImageName(win_list[i]);"
			fi
		elif [ "$TYPE" = "D" ]
		then
			if [ "$STAT" != "D" ]
			then
				STAT="D"
			fi
			DEF=`echo $line | awk -F\| '{print $1}'`
			BUTTON_TYPE=`echo $DEF | awk '{print $2}'`
			BUTTON_NAME=`echo $DEF | awk '{print $3}'`
			PARAMETER=`echo $DEF | awk -F\" '{print $2}'`
			COMMANDS=`echo $line | awk -F\| '{print $2}'`
			if [ -z "$PARAMETER" ]
			then
				echo -e "\t\t$BUTTON_NAME = new $BUTTON_TYPE();"
			else
				echo -e "\t\t$BUTTON_NAME = new $BUTTON_TYPE(tr(\"$PARAMETER\"));"
			fi
			for cmd in $COMMANDS
			do
				echo -e "\t\t$BUTTON_NAME->$cmd;"
			done
			DEFINITIONS="${DEFINITIONS}\t$BUTTON_TYPE * $BUTTON_NAME;\n"
		elif [ "$TYPE" = "L" ]
		then
			if [ "$STAT" = "D" ]
			then
				LAYOUT_NAME=$BUTTON_NAME
				LAYOUT_TYPE=$BUTTON_TYPE
				STAT="L"
			fi
			if [ "$LAYOUT_TYPE" = "QGridLayout" ]; then
				ROW=`echo $line | awk '{print $2}'`
				COL=`echo $line | awk '{print $3}'`
				OBJ=`echo $line | awk '{print $4}'`
				WID=`echo $line | awk '{print $5}'`
				HIG=`echo $line | awk '{print $6}'`
				PAR=`echo $line | awk '{print $5}'`

				if [ "$HIG" != "" ]
				then
					echo -e "\t\t$LAYOUT_NAME->addWidget($OBJ, $ROW, $COL, $WID, $HIG);"
				elif [ "$PAR" != "" ]
				then
					echo -e "\t\t$LAYOUT_NAME->addWidget($OBJ, $ROW, $COL, $PAR);"
				else
					echo -e "\t\t$LAYOUT_NAME->addWidget($OBJ, $ROW, $COL);"
				fi
			else
				OBJ=`echo $line | awk '{print $2}'`
				PAR1=`echo $line | awk '{print $3}'`
				PAR2=`echo $line | awk '{print $4}'`
				if [ "$PAR1" = "" ]; then
					echo -e "\t\t$LAYOUT_NAME->addWidget($OBJ);"
				elif [ "$PAR2" = "" ];then
					echo -e "\t\t$LAYOUT_NAME->addWidget($OBJ,$PAR1);"
				else
					echo -e "\t\t$LAYOUT_NAME->addWidget($OBJ,$PAR1,$PAR2);"
				fi
			fi
		elif [ "$TYPE" = "C" ]
		then
			STAT="C"
			SIG_OBJ=`echo $line | awk '{print $2}'`
			SIG_ACT=`echo $line | awk '{print $3}'`
			SLT_OBJ=`echo $line | awk '{print $4}'`
			SLT_ACT=`echo $line | awk '{print $5}'`
			i=0
			while [[ "$i" -lt "${#SLOT_FUNCS[@]}" && "${SLOT_FUNCS[$i]}" != "$SLT_ACT" ]]
			do 
				i=$[i+1]
			done
			if [ "$i" = "${#SLOT_FUNCS[@]}" ]; then SLOT_FUNCS=("${SLOT_FUNCS[@]}" "$SLT_ACT"); fi
			echo -e "\t\tconnect($SIG_OBJ, SIGNAL($SIG_ACT), $SLT_OBJ, SLOT($SLT_ACT));"
		elif [ "$TYPE" = "U" ]
		then
			VAR_TYPE=`echo $line | awk '{print $2}'`
			VAR_NAME=`echo $line | awk '{print $3}'`
			VAR_VALUE=`echo $line | awk -F\| '{print $2}'`
			UPDATE_DEFS="${UPDATE_DEFS}\t$VAR_TYPE $VAR_NAME;\n"
			UPDATE_CODES="${UPDATE_CODES}\t\t$VAR_NAME = $VAR_VALUE;\n"
		elif [ "$TYPE" = "R" ]
		then
			STAT="D"
			OBJ=`echo $line | awk '{print $2}'`
			CMD=`echo $line | awk -F\| '{print $2}'`
			CMD=`echo $CMD`
			echo -e "\t\t$OBJ->$CMD;"
		fi
	done < $TEMPLATE
	echo -e "\t}"
	echo ""
	echo -e "\t~$CLASS_NAME(){}"
	echo ""
	echo "public slots:"
	i=0
	while [ "$i" -lt ${#SLOT_FUNCS[@]} ]
	do
		if [ "${SLOT_FUNCS[$i]}" != "update()" ]; then
			echo -e "\tvoid ${SLOT_FUNCS[$i]}"
			echo -e "\t{"
			echo -e "\t}"
		else
			echo -e "\tvoid update()"
			echo -e "\t{"
			echo -e "$UPDATE_CODES"
			echo -e "\t}"
		fi
		i=$[i+1]
		echo ""
	done
	echo "public:"
	echo -ne "$UPDATE_DEFS"
	echo -ne "$DEFINITIONS"
	echo -e "\tV3DPluginCallback2 * callback;"
	echo -e "\tv3dhandle curwin;"
	echo "};"
	echo ""
	echo "#endif"
fi > $OUTPUT_FILE

echo "finish"
