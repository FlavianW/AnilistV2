1) Pour lancer le projet, n'oubliez pas de taper "flutter pub get", la page de démarrage est main.dart


2) Pour accéder à l'application, il vous faut un compte. Cliquez sur "Créer un compte"

3) Entrez un pseudo, un mail et un mot de passe d'au moins 6 caracteres.
Pour créer le systeme d'authentification j'ai utilisé Google Authentification. Le SQLite intervient
ici aussi car il stocke le pseudo et le mail en tant que clé primaire pour se souvenir du pseudo de la personne.

4) Lorsque vous avez cliqué sur "S'inscrire" vous serez redirigé vers la page de connexion ou vous 
pourrez vous connecter, connectez vous.

5) Vous êtes maintenant sur l'accueil, ici vous pouvez chercher un animé pour avoir les informations le concernant.
Pour faire cette partie j'ai utilisé l'API jikan.moe, c'est une API qui répertorie les animés sur le site MyAnimeList.
Sur la page d'accueil, cela appelle  l'endpoint https://api.jikan.moe/v4/anime?q={ANIME}&sfw avec ANIME étant la
recherche de l'utilisateur. Pour l'affichage j'ai utilisé une grid avec des Card.
Un popup s'affiche si la requête ne renvoie rien du tout. Par exemple en tapant des nombres au hasard.

6) Lorsque vous cliquez sur une Card, vous êtes redirigé vers la page de l'animé, ici vous pouvez voir les 
informations concernant l'animé, comme le synopsis, le nombre d'épisodes, le nom du studio, l'année de sortie et l'image en plus grand.
Pour avoir plus d'informations sur l'animé, j'ai appelé l'endpoint https://api.jikan.moe/v4/anime/{ID}/full avec ID étant
le mal_id, c'est un identifiant unique utilisé sur myanimelist et que l'on récupère dans l'endpoint précédent.
J'ai utilisé une liste de inkwell pour afficher le studio, le nombre d'épisodes, l'année de sortie et le studio.

7) L'utilisateur peut à tout moment revenir en arrière avec la flèche en haut à gauche.