local LootDistr, LDData = ...

localeBasedMessages = {
    ["enUS"] = {
        system = {
            addonLoaded = "Addon Loaded",
            moduleEnabled = "Loot roll module enabled.",
            moduleDisabled = "Loot roll module disabled.",
            joinedRaid = "You have joined the raid group. Loot Watcher activated. Loot treshold:",
            leftRaid = "You have left the raid group. Loot Watcher deactivated.",
            trackedLoot = "Tracked loot:",
            lootRollingEnded = "Loot Rolling ended.",
            reRollConfirmed = "Re-roll confirmed.",
            noEligibleReRolls = "No eligible re-rolls.",
            noItemRolling = "No item is currently being rolled.",
            softResImported = "Imported soft reserves!",
            softResOverwrite = "Soft reserve data already exists. Importing new data will overwrite it. Continue?",
            csvParseError = "CSV parse error:",
            lootWatcherDataDeleted = "All loot watcher data has been deleted.",
            rollStartWithReserves = "Roll for: %s - Reserved by: %s",
            rollStartNoReserves = "Roll for: %s - No soft reserves",
            rollEndedWinner = "Rolling ended. Winner: %s with roll - %d",
            rollEndedNoRolls = "Rolling ended. No rolls recorded.",
            itemIDError = "Could not get itemID or link.",
            notLootMaster = "You are not the loot master.",
            notInRaid = "You are not in the raid group.",
            lootNotMaster = "Master loot is not enabled. Current loot system: %s",
            noCSVText = "No CSV text to import!",
            invalidCSVFormat = "Not a valid CSV format (missing commas or header row).",
            missingCSVColumn = "CSV is missing required column: |cffffff00%s|r",
            softResDeleted = "All soft reserves have been deleted."
        },
        dialogs = {
            confirmEndRoll = "Are you sure you want to end rolling?",
            confirmReRoll = "Are you sure you want to re-roll this item?",
            confirmOverwrite = "Soft reserve data already exists. Importing new data will overwrite it. Continue?",
            confirmDeleteWatcher = "Are you sure you want to delete ALL loot watcher data? This cannot be undone.",
            confirmDeleteSoftRes = "Are you sure you want to delete ALL soft reserves data? This cannot be undone.",
            yes = "Yes",
            no = "No"
        },
        regex = {
            playerLoot = "^(.+) receives loot: (.+)%.$",
            selfLoot = "^You receive loot: (.+)%.$",
            goldShare = "Your share of the loot is",
            gold = "(%d+)%s*gold",
            silver = "(%d+)%s*silver",
            copper = "(%d+)%s*copper",
            systemRoll = "^(%S+) rolls (%d+) %((%d+)%-(%d+)%)$"
        },
        ui = {
            searchReserves = "Search reserves...",
            searchLoot = "Search loot..."
        }
    },

    ["frFR"] = {
        system = {
            addonLoaded = "Add-on chargé",
            moduleEnabled = "Module de jet de dés activé.",
            moduleDisabled = "Module de jet de dés désactivé.",
            joinedRaid = "Vous avez rejoint le groupe de raid. Surveillant de butin activé. Seuil :",
            leftRaid = "Vous avez quitté le groupe de raid. Surveillant de butin désactivé.",
            trackedLoot = "Butin suivi :",
            lootRollingEnded = "Jet de dés terminé.",
            reRollConfirmed = "Rejet confirmé.",
            noEligibleReRolls = "Aucun rejet possible.",
            noItemRolling = "Aucun objet actuellement en cours de jet.",
            softResImported = "Réservations importées !",
            softResOverwrite = "Les données de réservations existent déjà. Les importer écrasera les anciennes. Continuer ?",
            csvParseError = "Erreur d'analyse CSV :",
            lootWatcherDataDeleted = "Toutes les données de surveillance du butin ont été supprimées.",
            rollStartWithReserves = "Jet pour : %s - Réservé par : %s",
            rollStartNoReserves = "Jet pour : %s - Aucune réservation",
            rollEndedWinner = "Jet terminé. Gagnant : %s avec un jet de %d",
            rollEndedNoRolls = "Jet terminé. Aucun jet enregistré.",
            itemIDError = "Impossible d’obtenir l’ID ou le lien de l’objet.",
            notLootMaster = "Vous n’êtes pas le maître du butin.",
            notInRaid = "Vous n’êtes pas dans un groupe de raid.",
            lootNotMaster = "Le butin maître n’est pas activé. Système actuel : %s",
            noCSVText = "Aucun texte CSV à importer !",
            invalidCSVFormat = "Format CSV non valide (il manque des virgules ou l’en-tête).",
            missingCSVColumn = "Il manque la colonne obligatoire : |cffffff00%s|r",
            softResDeleted = "Toutes les réservations ont été supprimées."
        },
        dialogs = {
            confirmEndRoll = "Voulez-vous vraiment mettre fin au jet ?",
            confirmReRoll = "Voulez-vous vraiment relancer cet objet ?",
            confirmOverwrite = "Les données de réservation existent déjà. Les importer écrasera les anciennes. Continuer ?",
            confirmDeleteWatcher = "Voulez-vous vraiment supprimer TOUTES les données de surveillance du butin ? Ceci est irréversible.",
            confirmDeleteSoftRes = "Voulez-vous vraiment supprimer TOUTES les données de réservations ? Ceci est irréversible.",
            yes = "Oui",
            no = "Non"
        },
        regex = {
            playerLoot = "^(.+) reçoit le butin : (.+)%.$",
            selfLoot = "^Vous recevez le butin : (.+)%.$",
            goldShare = "Votre part du butin est",
            gold = "(%d+)%s*or",
            silver = "(%d+)%s*argent",
            copper = "(%d+)%s*cuivre",
            systemRoll = "^(%S+) obtient un (%d+) %((%d+)%-(%d+)%)$"
        },
        ui = {
            searchReserves = "Rechercher réservations...",
            searchLoot = "Rechercher butin..."
        }
    },

    ["deDE"] = {
        system = {
            addonLoaded = "Addon geladen",
            moduleEnabled = "Würfelmodul aktiviert.",
            moduleDisabled = "Würfelmodul deaktiviert.",
            joinedRaid = "Du bist der Schlachtgruppe beigetreten. Beuteüberwachung aktiviert. Schwelle:",
            leftRaid = "Du hast die Schlachtgruppe verlassen. Beuteüberwachung deaktiviert.",
            trackedLoot = "Verfolgte Beute:",
            lootRollingEnded = "Würfeln beendet.",
            reRollConfirmed = "Neuwurf bestätigt.",
            noEligibleReRolls = "Keine gültigen Neuwürfe.",
            noItemRolling = "Kein aktueller Wurfgegenstand.",
            softResImported = "Reservierungen importiert!",
            softResOverwrite = "Reservierungsdaten existieren bereits. Neue Daten werden sie überschreiben. Fortfahren?",
            csvParseError = "CSV-Fehler:",
            lootWatcherDataDeleted = "Alle Beutedaten wurden gelöscht.",
            rollStartWithReserves = "Würfeln für: %s - Reserviert von: %s",
            rollStartNoReserves = "Würfeln für: %s - Keine Reservierungen",
            rollEndedWinner = "Würfeln beendet. Gewinner: %s mit einem Wurf von %d",
            rollEndedNoRolls = "Würfeln beendet. Keine Würfe aufgezeichnet.",
            itemIDError = "Konnte Gegenstands-ID oder Link nicht abrufen.",
            notLootMaster = "Du bist nicht der Plündermeister.",
            notInRaid = "Du bist nicht in einer Schlachtgruppe.",
            lootNotMaster = "Plündermeister ist nicht aktiviert. Aktuelles System: %s",
            noCSVText = "Kein CSV-Text zum Importieren!",
            invalidCSVFormat = "Ungültiges CSV-Format (fehlende Kommata oder Kopfzeile).",
            missingCSVColumn = "CSV fehlt erforderliche Spalte: |cffffff00%s|r",
            softResDeleted = "Alle Reservierungen wurden gelöscht."
        },
        dialogs = {
            confirmEndRoll = "Bist du sicher, dass du das Würfeln beenden willst?",
            confirmReRoll = "Willst du wirklich für dieses Item neu würfeln?",
            confirmOverwrite = "Reservierungsdaten existieren bereits. Neue Daten werden sie überschreiben. Fortfahren?",
            confirmDeleteWatcher = "Willst du wirklich ALLE Beutedaten löschen? Das kann nicht rückgängig gemacht werden.",
            confirmDeleteSoftRes = "Willst du wirklich ALLE Reservierungsdaten löschen? Dies kann nicht rückgängig gemacht werden.",
            yes = "Ja",
            no = "Nein"
        },
        regex = {
            playerLoot = "^(.+) erhält Beute: (.+)%.$",
            selfLoot = "^Ihr erhaltet Beute: (.+)%.$",
            goldShare = "Ihr Anteil an der Beute ist",
            gold = "(%d+)%s*Gold",
            silver = "(%d+)%s*Silber",
            copper = "(%d+)%s*Kupfer",
            systemRoll = "^(%S+) würfelt (%d+) %((%d+)%-(%d+)%)$"
        },
        ui = {
            searchReserves = "Reservierungen suchen...",
            searchLoot = "Beute durchsuchen..."
        }
    },

    ["ruRU"] = {
        system = {
            addonLoaded = "Аддон загружен",
            moduleEnabled = "Модуль бросков активирован.",
            moduleDisabled = "Модуль бросков отключён.",
            joinedRaid = "Вы присоединились к рейду. Слежение за добычей включено. Порог:",
            leftRaid = "Вы покинули рейд. Слежение за добычей выключено.",
            trackedLoot = "Отслежена добыча:",
            lootRollingEnded = "Броски завершены.",
            reRollConfirmed = "Пере-бросок подтвержден.",
            noEligibleReRolls = "Нет подходящих пере-бросков.",
            noItemRolling = "Нет предмета для броска.",
            softResImported = "Резервы загружены!",
            softResOverwrite = "Данные резервов уже существуют. Новые данные их перезапишут. Продолжить?",
            csvParseError = "Ошибка разбора CSV:",
            lootWatcherDataDeleted = "Все данные слежения за добычей удалены.",
            rollStartWithReserves = "Ролл на: %s - Зарезервировано: %s",
            rollStartNoReserves = "Ролл на: %s - Нет резервов",
            rollEndedWinner = "Броски завершены. Победитель: %s с броском — %d",
            rollEndedNoRolls = "Броски завершены. Броски не зафиксированы.",
            itemIDError = "Не удалось получить itemID или ссылку.",
            notLootMaster = "Вы не раздатчик добычи.",
            notInRaid = "Вы не в рейд-группе.",
            lootNotMaster = "Мастерская добыча не включена. Текущая система: %s",
            noCSVText = "Нет текста CSV для импорта!",
            invalidCSVFormat = "Недопустимый формат CSV (отсутствуют запятые или заголовки).",
            missingCSVColumn = "В CSV отсутствует обязательный столбец: |cffffff00%s|r",
            softResDeleted = "Все резервы были удалены."
        },
        dialogs = {
            confirmEndRoll = "Вы уверены, что хотите завершить броски?",
            confirmReRoll = "Вы уверены, что хотите пере-бросить этот предмет?",
            confirmOverwrite = "Данные резервов уже существуют. Продолжить и перезаписать?",
            confirmDeleteWatcher = "Вы уверены, что хотите удалить ВСЕ данные наблюдателя за добычей? Это нельзя отменить.",
            confirmDeleteSoftRes = "Вы уверены, что хотите удалить ВСЕ данные резервов? Это действие необратимо.",
            yes = "Да",
            no = "Нет"
        },
        regex = {
            playerLoot = "^(.+) получает добычу: (.+)%.$",
            selfLoot = "^Вы получаете добычу: (.+)%.$",
            goldShare = "Ваша доля добычи:",
            gold = "(%d+)%s*золота",
            silver = "(%d+)%s*серебра",
            copper = "(%d+)%s*меди",
            systemRoll = "^(%S+) бросает (%d+) %((%d+)%-(%d+)%)$"
        },
        ui = {
            searchReserves = "Поиск резервов...",
            searchLoot = "Поиск добычи..."
        }
    },

    ["esES"] = {
        system = {
            addonLoaded = "Addon cargado",
            moduleEnabled = "Módulo de tirada activado.",
            moduleDisabled = "Módulo de tirada desactivado.",
            joinedRaid = "Te has unido al grupo de banda. Observador de botín activado. Umbral:",
            leftRaid = "Has abandonado el grupo de banda. Observador de botín desactivado.",
            trackedLoot = "Botín rastreado:",
            lootRollingEnded = "Tirada finalizada.",
            reRollConfirmed = "Repetición confirmada.",
            noEligibleReRolls = "No hay repeticiones válidas.",
            noItemRolling = "No hay objeto en tirada actualmente.",
            softResImported = "¡Reservas importadas!",
            softResOverwrite = "Los datos de reservas ya existen. ¿Deseas sobrescribirlos?",
            csvParseError = "Error de análisis CSV:",
            lootWatcherDataDeleted = "Todos los datos del observador de botín han sido eliminados.",
            rollStartWithReserves = "Tirada por: %s - Reservado por: %s",
            rollStartNoReserves = "Tirada por: %s - Sin reservas",
            rollEndedWinner = "Tirada finalizada. Ganador: %s con una tirada de %d",
            rollEndedNoRolls = "Tirada finalizada. No se registraron tiradas.",
            itemIDError = "No se pudo obtener itemID o enlace.",
            notLootMaster = "No eres el maestro despojador.",
            notInRaid = "No estás en el grupo de banda.",
            lootNotMaster = "El botín maestro no está habilitado. Sistema actual: %s",
            noCSVText = "¡No hay texto CSV para importar!",
            invalidCSVFormat = "Formato CSV no válido (faltan comas o encabezado).",
            missingCSVColumn = "Falta columna obligatoria en CSV: |cffffff00%s|r",
            softResDeleted = "Todas las reservas han sido eliminadas."
        },
        dialogs = {
            confirmEndRoll = "¿Estás seguro de que quieres finalizar la tirada?",
            confirmReRoll = "¿Estás seguro de que quieres repetir la tirada de este objeto?",
            confirmOverwrite = "Los datos de reservas ya existen. ¿Deseas sobrescribirlos?",
            confirmDeleteWatcher = "¿Estás seguro de que quieres eliminar TODOS los datos del observador de botín? Esto no se puede deshacer.",
            confirmDeleteSoftRes = "¿Estás seguro de que quieres eliminar TODOS los datos de reservas? Esto no se puede deshacer.",
            yes = "Sí",
            no = "No"
        },
        regex = {
            playerLoot = "^(.+) recibe botín: (.+)%.$",
            selfLoot = "^Recibes botín: (.+)%.$",
            goldShare = "Tu parte del botín es",
            gold = "(%d+)%s*oro",
            silver = "(%d+)%s*plata",
            copper = "(%d+)%s*cobre",
            systemRoll = "^(%S+) tira los dados y obtiene (%d+) %((%d+)%-(%d+)%)$"
        },
        ui = {
            searchReserves = "Buscar reservas...",
            searchLoot = "Buscar botín..."
        }
    }
}

currentLocale = GetLocale() or "enUS"
LDData.messages = localeBasedMessages[currentLocale]