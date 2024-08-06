using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }

# Global countdown timer class, pass in players to display time on their screen
MakeCountdownTimer<constructor><public>(Time : float, ?MaybeInPlayersUIs : []player_ui) := countdown_timer:
    InitialTime := Time
    MaybePlayersUIs := MaybeInPlayersUIs

countdown_timer := class:
    
    var InitialTime<internal> : float = 0.0
    var RemainingTime<internal> : float = 0.0
    var CountdownStarted<internal> : logic = false
    # How often (in seconds) is timer updated
    TimerTickPeriod<private> : float = 1.0

    # Storing widgets for later use
    MaybePlayersUIs : []player_ui = array{}
    RemainingTimeText<localizes>(CurrentRemainingTime : int) : message = "TIME LEFT: {CurrentRemainingTime}"
    var RemainingTimeWidgets : []text_block = array{}
    var CanvasWidgets: []canvas = array{}

    # Events to subscribe to coresponding to countdown events
    CountdownStartedEvent<public>: event() = event(){}
    CountdownUpdatedEvent<public>: event(float) = event(float){}
    CountdownFinishedEvent<public>: event() = event(){}

    StartCountdown<public>() : void =
        for (MaybePlayerUI : MaybePlayersUIs):
            NewRemainingTimeWidget : text_block = text_block{DefaultTextColor := NamedColors.White}
            CanvasWidget: canvas = CreateUI(NewRemainingTimeWidget)

            # Storing widgets for later use
            set RemainingTimeWidgets = RemainingTimeWidgets + array{NewRemainingTimeWidget}
            set CanvasWidgets = CanvasWidgets + array{CanvasWidget}

            MaybePlayerUI.AddWidget(CanvasWidget)

        spawn:
            RunCountdown()

    GetRemainingTime<public>(): float = 
        return RemainingTime

    SetMaxTime<public>(Time : float): void = 
        set InitialTime = Time

    StopCountdown<public>(): void = 
        set CountdownStarted = false
    
    RunCountdown<private>()<suspends> : void =
        set RemainingTime = InitialTime
        set CountdownStarted = true
        CountdownStartedEvent.Signal()
        loop:
            UpdateUI()
            Sleep(TimerTickPeriod)
            CountdownUpdatedEvent.Signal(RemainingTime)
            set RemainingTime -= TimerTickPeriod
            if (RemainingTime <= 0.0 or not CountdownStarted?):
                RemoveUI()
                break
        set CountdownStarted = false
        CountdownFinishedEvent.Signal()

    CreateUI(RemainingTimeWidget: text_block): canvas =
        UI := canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors:
                        Minimum := vector2{X := 0.5, Y := 0.05}
                        Maximum := vector2{X := 0.5, Y := 0.05}
                    Alignment := vector2{X := 0.5, Y := 0.0}
                    Offsets := margin{Top := 0.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
                    SizeToContent := true
                    Widget := RemainingTimeWidget 

    UpdateUI(): void = 
        if (IntTime := Int[RemainingTime]):
            for (RemainingTimeWidget : RemainingTimeWidgets):
                RemainingTimeWidget.SetText(RemainingTimeText(IntTime))

    RemoveUI(): void = 
        for (MaybePlayerUI : MaybePlayersUIs):
            for (CanvasWidget : CanvasWidgets):
                MaybePlayerUI.RemoveWidget(CanvasWidget)

