list_of_packages <- c("shiny", "xml2", "shinyFiles")

new_packages <- list_of_packages[!(list_of_packages %in% installed.packages()[, "Package"])]

if (length(new_packages) > 0) {
    install.packages(new_packages, dependencies = TRUE)
    print(paste0("The following package was installed:", new_packages))
} else if (length(new_packages) == 0) {
    print("All packages were already installed previously")
}

# Chargement de toutes les bibliotheques necessaires en une seule fois
invisible(lapply(list_of_packages, library, character.only = TRUE, quietly = TRUE))

# FIN packages -----------------------------------------------------------------


ui <- fluidPage(
    titlePanel("Formulaire de métadonnées XML"),
    sidebarLayout(
        sidebarPanel(
            textInput("nomPrenom", "Nom de famille et Prénom"),
            textInput("titreProjet", "Titre du projet"),
            textInput("motsCles", "Mots-clés (séparés par des virgules)"),
            # shinyDirButton('folder', 'Folder select', 'Please select a folder', FALSE),
            # shinyFilesButton("fichierResume", "Télécharger un résumé (Word ou PDF)", "Sélectionnez un fichier", multiple = FALSE, filetype = c("txt", "csv", "docx", "pdf", "doc"))
            fileInput("fichierResume",
                "Télécharger un résumé (Word ou PDF)",
                multiple = FALSE,
                accept = c("txt", "csv", "docx", "pdf", "doc")
            ),
            br(),
            actionButton("saveBtn", "Exporter en XML")
        ),
        mainPanel(
            h4("Aperçu du résumé"),
            textOutput(input$fichierResume)
            # h4("Aperçu des métadonnées saisies :"),
            # verbatimTextOutput("metadataOutput")
        )
    )
)

server <- function(input, output, session) {
    # shinyDirChoose(input, "folder", roots=c(wd="/./"))
    shinyFileChoose(input,
        "fichierResume",
        roots = c(wd = "."),
        filetype = c("txt", "csv", "docx", "pdf", "doc")
    )


    observeEvent(input$saveBtn, {
        # Construire le fichier XML à partir des valeurs saisies
        nomPrenom <- input$nomPrenom
        titreProjet <- input$titreProjet
        motsCles <- unlist(strsplit(input$motsCles, ","))
        fichierResume <- input$fichierResume

        # Créer un document XML
        doc <- xml_new_document("1.0")
        metadata <- xml_add_child(doc, "metadata")

        # Ajouter des éléments XML pour les métadonnées
        xml_add_child(
            metadata,
            "title",
            titreProjet
        )
        creator <- xml_add_child(metadata, "creator")

        xml_add_child(creator, "surName", nomPrenom)


        keywords <- xml_add_child(metadata, "keywords")

        for (mot in motsCles) {
            xml_add_child(keywords, "keyword", mot)
        }

        xml_add_child(
            metadata,
            "fichierresume",
            unlist(fichierResume)[which.max(nchar(unlist(fichierResume)))]
        )

        print(doc)

        # # Vérifier si un fichier de résumé a été téléchargé
        # if (!is.null(input$fichierResume$path)) {
        #     fichier <- input$fichierResume$path
        #     # Vous pouvez accéder au fichier avec fichier

        #     # Pour illustrer, affichons le chemin du fichier de résumé
        #     cat("Chemin du fichier de résumé :", fichier, "\n")
        # }





        # Sauvegarder le document XML en tant que fichier
        write_xml(doc, paste0(getwd(), "/metadata.xml"))

        # Afficher les métadonnées dans l'aperçu
        output$metadataOutput <- renderPrint({
            as.character(doc)
        })
    })
}

shinyApp(ui, server)
