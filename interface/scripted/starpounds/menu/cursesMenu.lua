function curses:onClick()
    player.interact(
        "ScriptPane", 
        { 
            gui = {}, 
            scripts = {"/metagui.lua"}, 
            ui = "curseofcorpulence:curses"
        }
    )
    pane.dismiss()
end
