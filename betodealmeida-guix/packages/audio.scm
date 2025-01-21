(define-module (betodealmeida-guix packages audio)
  #:use-module (guix)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages sdl)
  #:use-module (gnu packages xorg))

(define-public argotlunar
  (package
    (name "argotlunar")
    (version "2.1.0")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/mourednik/argotlunar.git")
             (commit "2.1.0"))) 
       (file-name (git-file-name name version))
       (sha256
        (base32 "00fzk3ak4lwjn06wif85hbahsxf2bvv9r10a3cvzd4ywb981jvak"))
       (patches
        (list
         (local-file "./argotlunar-disable-copy.patch")))))
    (build-system cmake-build-system)
    (inputs
     `(("alsa-lib" ,alsa-lib)
       ("freetype" ,freetype)
       ("libx11" ,libx11)
       ("libxcursor" ,libxcursor)
       ("libxext" ,libxext)
       ("libxinerama" ,libxinerama)
       ("libxrandr" ,libxrandr)
       ("libxshmfence" ,libxshmfence)
       ("pkg-config" ,pkg-config)
       ("sdl2" ,sdl2)
       ("xorg-server" ,xorg-server)))
    (arguments
     `(#:tests? #f
       #:configure-flags
       (list (string-append "-DCMAKE_INSTALL_PREFIX=" (assoc-ref %outputs "out"))
             "-DJUCE_COPY_PLUGIN_AFTER_BUILD=OFF"
             "-DJUCE_VST3_AUTO_MANIFEST=OFF")
       #:phases
       (modify-phases %standard-phases
         (add-after 'install 'install-vst3
           (lambda* (#:key outputs #:allow-other-keys)
             (let* ((out (assoc-ref outputs "out"))
                    (vst3-dir (string-append out "/lib/vst3")))
               (mkdir-p vst3-dir)
               (display "\nContents before VST3 copy:\n")
               (system "ls -R")
               (copy-recursively
                "./Argotlunar_artefacts/RelWithDebInfo/VST3/Argotlunar.vst3"
                (string-append vst3-dir "/Argotlunar.vst3"))
               #t))))))
    (home-page "https://github.com/mourednik/argotlunar")
    (synopsis "Surreal transformations of audio streams")
    (description "Argotlunar is a granulator plugin for AudioUnit / VST hosts.")
    (license license:gpl2+)))
