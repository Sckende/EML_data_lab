library(EML)

# Creation of EML file
me <- list(individualName = list(
    givenName = "Claire-Cécile",
    surName = "Juhasz"
))

my_eml <- list(dataset = list(
    title = "Species occurrences",
    creator = me,
    contact = me
))

write_eml(my_eml, "minimal_eml.xml")

# second method
my_eml2 <- eml$eml(
    # project = "Indicateurs de la biodiversité",
    individualName = list(
        givenName = "Claire-Cécile",
        surName = "Juhasz"
    )
)
