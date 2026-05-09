{ username, ... }:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [ "https://cache.lix.systems" ];
    extra-trusted-public-keys = [ "cache.lix.systems:aBnZUw8zA7H35Cz2RyKFVs3H4PlGTLawyY5KRbvJR8o=" ];
    trusted-users = [
      "@admin"
      username
    ];
  };
}
