these scripts are meant to be ran at the root path

0. Install first using `cmake --install build_folder`
1. Edit release template
2. `bump_version.ps1`
3. `update_intaller.ps1` (if changes are made)
4. `generate_release_notes.ps1` ->(triggers)-> `update_repository.ps1`
5. commit and push
