## ▶️ Come eseguire lo script

1. Crea un ambiente virtuale:
   ```bash
   python -m venv .venv
    ```
2. Attiva l'ambiente virtuale:
    - Su Windows:
        ```bash
        .venv\Scripts\activate
        ```
    - Su macOS/Linux:
        ```bash
        source .venv/bin/activate
        ```
3. Installa le dipendenze:
    ```bash
    pip install -r requirements.txt
    ```
4. Esegui gli script:
    ```bash
    python nome_script.py
    ```
    
## 💾 Aggiunta nuove librerie

Per aggiungere nuove librerie, installale nell'ambiente virtuale e aggiorna il file `requirements.txt`:
```bash
pip install nome_libreria
pip freeze > requirements.txt
```
