{
  vimUtils,
  src,
}:

vimUtils.buildVimPlugin {
  pname = "laravel-nvim";
  version = src.shortRev or "unstable";
  inherit src;
  doCheck = false;
}
