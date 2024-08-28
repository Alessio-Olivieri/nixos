{ pkgs, ... }:
{
    programs.plasma = {
        enable = true;

        desktop.widgets = [
            {
                config = {
                Appearance = {
                    showDate = false;
                };
                };
                name = "org.kde.plasma.digitalclock";
                position = {
                horizontal = 51;
                vertical = 100;
                };
                size = {
                height = 250;
                width = 250;
                };
            }
        ];
    };
}