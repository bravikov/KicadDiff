#!/bin/bash
# Автор: bravikov@gmail.com

# Скрипт, вызываемый Git'ом, для сравнения Kicad-схем ввиде svg-файлов.
# Скрипт сливает схемы в одно png-изображение, где
# удаленное - красным цветов, а добавленное - зеленым.
#
# Вызов: ./kicad-diff.sh path old-file old-hex old-mode new-file new-hex new-mode
# где:
#   path - имя файла
#   <old|new>-file - старая и новая версия файла
#   <old|new>-hex - SHA1-хеши из 40 шестнадцатеричных цифр
#   <old|new>-mode - восьмеричное представление прав доступа для файлов
# В параметры могут входить пользовательские рабочие файлы (например new-file из "git-diff-files"),
# /dev/null (например old-file при добавлении нового файла) или временные файлы (например old-file из индекса).
#

echo Вызов $0 для $1

if [ $# -ne 7 ]
    then
        echo "$0: Неправильные аргументы" 1>&2
        exit 1
fi

OLD_FILE=$2
NEW_FILE=$5

OLD_PNG_FILE="/tmp/kicad-diff-old-$1.png"
NEW_PNG_FILE="/tmp/kicad-diff-new-$1.png"
RESULT_FILE="/tmp/kicad-diff-$1.png"


# Проверить существование утилит imagemagiсk
if [[ ! (-x `which convert`) || ! (-x `which composite`) ]];
    then
        echo "$0: Ненайдены утилиты imagemagiсk" 1>&2
        exit 1
fi

# Получить сравнение

OLD_FILE_EXISTS="no"
NEW_FILE_EXISTS="no"

if [[ "$OLD_FILE" != "/dev/null" ]]
    then
        convert -black-threshold 100% -fill red -opaque black -density 130 "$OLD_FILE" "$OLD_PNG_FILE"
        OLD_FILE_EXISTS="yes"
fi

if [[ "$NEW_FILE" != "/dev/null" ]]
    then
        convert -black-threshold 100% -fill green -opaque black -density 130 "$NEW_FILE" "$NEW_PNG_FILE"
        NEW_FILE_EXISTS="yes"
fi

if [[ "$OLD_FILE_EXISTS" == "yes" && "$NEW_FILE_EXISTS" == "yes" ]]
    then
        composite -blend 50% -density 130 "$OLD_PNG_FILE" "$NEW_PNG_FILE" "$RESULT_FILE"
        rm "$OLD_PNG_FILE" "$NEW_PNG_FILE"

    elif [[ "$OLD_FILE_EXISTS" == "yes" && "$NEW_FILE_EXISTS" == "no" ]]
        then
            mv -f "$OLD_PNG_FILE" "$RESULT_FILE"

    elif [[ "$OLD_FILE_EXISTS" == "no" && "$NEW_FILE_EXISTS" == "yes" ]]
        then
            mv -f "$NEW_PNG_FILE" "$RESULT_FILE"

    else
        echo "$0: WTF?" 1>&2
        exit 1
fi

# Запустить просмотрщик изображений по умолчанию, с проверкой существования утилит запуска
if [ "$OS" = "Windows_NT" ]
    then
        if [[ -x `which start` ]]
            then start "$RESULT_FILE"
            else "$0: Не возможно отобразить сравнение" 1>&2
            exit 1
        fi
    else
        if [[ -x `which xdg-open` ]]
            then xdg-open "$RESULT_FILE"
            else "$0: Не возможно отобразить сравнение" 1>&2
            exit 1
        fi
fi

exit 0

