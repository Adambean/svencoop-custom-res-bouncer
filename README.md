# Sven Co-op custom resource bouncer

This tool will mitigate the blight of uncreative Sven Co-op server operators bombarding your game with truckloads of player models and sounds you do not want. It takes in lists of download paths of resources you don't want and replaces them with either the stock "helmet" player model or an empty file. This prevents Sven Co-op from downloading them again in game because the files already exist, as it refuses to overwrite existing files during content downloading.

In effect you're bouncing those custom resources you don't want away from your game.

It will not overrule any official content, or any content you've intentionally installed into your "addon" content folder. Only the "downloads" folder used for in game downloads will be scanned and modified.

## Prerequisites

This is a command line utility currently available as a Bash script for both Linux and Windows (via Cygwin). A Windows batch command script is in progress.

The Bash script requires use of:

* basename
* cd
* cp
* dirname
* find
* ln *(Except on Windows)*
* mkdir
* printf
* pwd
* read
* realpath
* rm
* sed
* sort
* touch

## Getting Started

First you need to define a list of player models and/or sounds you want to filter out. You don't have to define both.

### Filtering player models

Create a text file called "filter-player-models.txt" in the same directory as this tool. There is an example file called "examples/player-models/filter-player-models.txt" you could copy to get started, containing just one entry as an example.

The contents of this file is a simple list of player models you do not wish to see in game split by lines.

For example:

```
anon
rage_admin
typical_anime_girl_31a
```

### Filtering sounds

Create a text file called "filter-sounds.txt" in the same directory as this tool. There is an example file at "examples/sounds/filter-sounds.txt" you could copy to get started, containing just one entry as an example.

The contents of this file is a list of directories and/or files you do not wish to hear in game split by lines relative to the "sound" game resource path.

For example:

```
chatsounds/
music/cheesyloadingtrack05.mp3
voicecommands/
```

All listed files, and files found in directories recursively, will be replaced by an empty file.

If you're specifying a whole directory you want to filter out you must end your line with a forward slash `/`. This matters because it determines what should be done if the directory doesn't yet exist. (Omitting the `/` won't cause a problem, it'll just limit the functionality of this tool.)

#### When handling exact file paths

For each file its directory is checked for existence. If it doesn't exist it'll be created, and an empty file will be created within. If the directory did exist but the file did not, then empty file will be created. If the file already exists it will be deleted then recreated as an empty file.

Using exact file paths allows you to pre-emptively block sounds before they first arrive, but requires you to know in advance what the file names will be.

#### When handling directories:

If the directory doesn't yet exist it will be created. No further action can be taken in this case because the tool cannot pre-emptively guess what sound files will arrive. If you know the directory will exist after joining a particular server you should join that server once, allow downloading to complete, then run this tool again.

If the directory exists it will be scanned recursively for all files within. Each file will be deleted then recreated as an empty file.

## Running

To run this tool open a command prompt or terminal, then execute it passing a path to your "Sven Co-op" folder as argument 1.

For example:

* On Windows natively:
  `deploy.cmd "C:\Program Files (x86)\Steam\Steamapps\common\Sven Co-op"` *(coming soon)*
* On Linux natively:
  `./deploy.sh ~/.steam/steamapps/common/Sven\ Co-op`
* On Windows via Cygwin:
  `./deploy.sh /cygdrive/C/Program\ Files\ (x86)/Steam/steamapps/common/Sven\ Co-op`

Listed player models will be replaced by the stock "helmet" model regardless of whether they already exist or not.

Listed sounds are handled differently depending on whether they are an exact file path or directory.

## Built With

* [Batch file](https://en.wikipedia.org/wiki/Batch_file) *(coming soon)*
* [Bash](https://www.gnu.org/software/bash/)

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/your/project/tags).

## Authors

* **Adam Reece** - *Initial work* - [Adambean](https://github.com/Adambean)

See also the list of [contributors](https://github.com/your/project/contributors) who participated in this project.

## License

Copyright 2020 Adam Reece

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.

You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the [License](LICENSE) for the specific language governing permissions and limitations under the License.
