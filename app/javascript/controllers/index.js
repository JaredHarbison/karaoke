import { application } from "controllers/application"
import CtaSizeController from "controllers/cta_size_controller"
import FlashController from "controllers/flash_controller"
import HelloController from "controllers/hello_controller"
import InstructionsController from "controllers/instructions_controller"
import PasswordStrengthController from "controllers/password_strength_controller"
import SongActionController from "controllers/song_action_controller"
import YoutubeSearchController from "controllers/youtube_search_controller"

application.register("cta-size", CtaSizeController)
application.register("flash", FlashController)
application.register("hello", HelloController)
application.register("instructions", InstructionsController)
application.register("password-strength", PasswordStrengthController)
application.register("song-action", SongActionController)
application.register("youtube-search", YoutubeSearchController)
