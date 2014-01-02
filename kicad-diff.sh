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

echo Вызов $0

if [ $# -ne 7 ]
    then
        echo Неправильные аргументы 1>&2
        exit 1
fi

OLD_FILE=$2
NEW_FILE=$5

OLD_PNG_FILE=/tmp/kicad-diff-old-file.png
NEW_PNG_FILE=/tmp/kicad-diff-new-file.png
RESULT_FILE="/tmp/kicad-diff-$1.png"

# Проверка существования утилит imagemagiсk
if [[ ! (-x `which convert`) || ! (-x `which composite`) ]];
    then
        echo "Ненайдены утилиты imagemagiсk"
        exit 1
fi

# Получить сравнение
convert -black-threshold 100% -fill red -opaque black -density 130 "$OLD_FILE" "$OLD_PNG_FILE"
convert -black-threshold 100% -fill green -opaque black -density 130 "$NEW_FILE" "$NEW_PNG_FILE"
composite -blend 50% -density 130 "$OLD_PNG_FILE" "$NEW_PNG_FILE" "$RESULT_FILE"

# Проверка существования утилит запуска

# Запустить просмотрщик изображений по умолчанию
if [ "$OS" = "Windows_NT" ]
    then
        if [[ -x `which start` ]]
            then start "$RESULT_FILE"
            else "Не возможно отобразить сравнение"
            exit 1
        fi
    else
        if [[ -x `which xdg-open` ]]
            then xdg-open "$RESULT_FILE"
            else "Не возможно отобразить сравнение"
            exit 1
        fi
fi

rm "$OLD_PNG_FILE" "$NEW_PNG_FILE"

exit 0

