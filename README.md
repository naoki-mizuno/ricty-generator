# ricty-generator

Yet another Ricty generator using Docker.

Note that "official support" of Ricty, by the original author, has ended as
mentioned in the [official website](https://rictyfonts.github.io/),
[here](https://github.com/rictyfonts/rictyfonts.github.io/commit/331d9c076c3c45f1ffe97125eac7f532c5c6d1eb),
and [here](https://qiita.com/sounisi5011/items/62e4da71458ca7ce73c7).

That doesn't mean that we can no longer use Ricty, and here I am, generating
Ricty with the latest Inconsolata, with settings that I usually use for Ricty
Discord.

Almost all of the code is from: https://github.com/tetutaro/dotfiles/tree/main/fonts

Rationale explained (in Japanese) at: https://qiita.com/tetutaro/items/f895a2ecb1360206aaba

## How to run

```
$ git clone https://github.com/naoki-mizuno/ricty-generator
$ cd ricty-generator
$ docker compose run ricty-generator
```

## License

MIT (Same as tetutaro/dotfiles)

## Author

Naoki Mizuno (naoki.mizuno.256@gmail.com) wrote the `Dockerfile`, `compose.yaml`, and the patches to `ricty_generator.sh`. `rename_ricty.py`, `ricty_discord_patcher.sh`, and the logic of `install.sh` was written by [tetutaro](http://github.comtetutaro). Ricty was created by [Yasunori Yusa](http://www.yusa.lab.uec.ac.jp/~yusa/).
