_:

{
  system.defaults = {
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.5;
      show-recents = false;
      minimize-to-application = true;
      mru-spaces = false;
      tilesize = 48;
      expose-animation-duration = 0.1;
      orientation = "bottom";
      expose-group-apps = true;

      wvous-br-corner = 2;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      ShowPathbar = true;
      ShowStatusBar = true;
      FXPreferredViewStyle = "clmv";
      _FXSortFoldersFirst = true;
      FXDefaultSearchScope = "SCcf";
      NewWindowTarget = "Home";
      QuitMenuItem = true;
    };

    trackpad = {
      Clicking = true;
      TrackpadThreeFingerDrag = false;
    };

    NSGlobalDomain = {
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
      ApplePressAndHoldEnabled = false;

      AppleInterfaceStyle = "Dark";
      # Tahoe icon/widget appearance: dark icons, not tied to the auto switch.
      AppleIconAppearanceTheme = "RegularDark";
      _HIHideMenuBar = false;
      AppleShowScrollBars = "Always";

      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;

      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      NSDocumentSaveNewDocumentsToCloud = false;
      AppleShowAllExtensions = true;

      # ctrl+cmd drag to move a window from anywhere in it.
      NSWindowShouldDragOnGesture = true;
    };

    WindowManager = {
      # Stage Manager off.
      GloballyEnabled = false;
      # Don't hide every window when the wallpaper gets clicked.
      EnableStandardClickToShowDesktop = false;
    };

    # Each display gets its own spaces (pairs with mru-spaces = false above).
    spaces.spans-displays = false;

    # Declarative machine — updates land via darwin-rebuild, not on Apple's schedule.
    SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

    # Skip the "downloaded from the internet, are you sure?" gatekeeper prompt.
    LaunchServices.LSQuarantine = false;

    screensaver = {
      askForPassword = true;
      askForPasswordDelay = 10;
    };

    screencapture = {
      location = "~/Pictures/Screenshots";
      type = "png";
      disable-shadow = true;
    };

    loginwindow = {
      GuestEnabled = false;
    };

    CustomUserPreferences = {
      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
    };
  };
}
