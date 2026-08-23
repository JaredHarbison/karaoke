import { application } from "controllers/application"
import CtaSizeController from "controllers/cta_size_controller"
import DisclosureController from "controllers/disclosure_controller"
import FlashController from "controllers/flash_controller"
import HelloController from "controllers/hello_controller"
import InstructionsController from "controllers/instructions_controller"
import PasswordStrengthController from "controllers/password_strength_controller"
import PauseDialogController from "controllers/pause_dialog_controller"
import ResponsiveTabsController from "controllers/responsive_tabs_controller"
import SongActionController from "controllers/song_action_controller"
import TimeOfDayController from "controllers/time_of_day_controller"
import YoutubePlayerController from "controllers/youtube_player_controller"
import YoutubeSearchController from "controllers/youtube_search_controller"

application.register("cta-size", CtaSizeController)
application.register("disclosure", DisclosureController)
application.register("flash", FlashController)
application.register("hello", HelloController)
application.register("instructions", InstructionsController)
application.register("password-strength", PasswordStrengthController)
application.register("pause-dialog", PauseDialogController)
application.register("responsive-tabs", ResponsiveTabsController)
application.register("song-action", SongActionController)
application.register("time-of-day", TimeOfDayController)
application.register("youtube-player", YoutubePlayerController)
application.register("youtube-search", YoutubeSearchController)
