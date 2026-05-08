# RVT2CNC

## EXE bouwen op GitHub

1. Maak een GitHub repository.
2. Upload alle bestanden uit deze zip naar de root van de repository.
3. Ga naar **Actions**.
4. Kies **Build RVT2CNC Installer**.
5. Klik **Run workflow**.
6. Na de build staat `RVT2CNC_Setup.exe` bij **Artifacts**.

## Release maken voor gebruikers

Maak een tag:

```text
v1.0.0
```

Push die tag naar GitHub. Dan maakt GitHub automatisch een Release asset:

```text
RVT2CNC_Setup.exe
```

Gebruikers kunnen die dan downloaden via:

```text
https://github.com/<jouwnaam>/RVT2CNC/releases/latest
```
