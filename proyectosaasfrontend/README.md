# 🧠 Proyecto SaaS - Calidad de Datos

Aplicación fullstack para **analizar y sanitizar bases de datos de clientes**, detectando errores y mejorando la calidad de la información.

---

## 🚀 Funcionalidades

### 🔍 Análisis de datos

* Validación de emails
* Detección de duplicados
* Validación de teléfonos
* Validación de DNI
* Validación de fechas
* Identificación de registros perfectos y con problemas

---

### 🧹 Sanitización

* Limpieza automática de datos inválidos
* Eliminación de duplicados (emails)
* Normalización de datos
* Generación de dataset limpio

---

### 📊 Dashboard

* Score de calidad de datos
* Métricas clave:

  * Registros totales
  * Registros perfectos
  * Registros utilizables
  * Registros con problemas
* Visualización de errores
* Ejemplos reales de datos incorrectos

---

## 🧱 Arquitectura

```
Frontend (React)
        ↓
Backend (.NET API)
        ↓
SQL Server
```

---

## 🛠️ Tecnologías

### Backend

* .NET 6 / 7
* SQL Server
* Stored Procedures
* ADO.NET

### Frontend

* React
* JavaScript
* Fetch API

---

## ⚙️ Instalación

### 1. Clonar repositorio

```bash
git clone https://github.com/TU-USUARIO/proyecto-saas-calidad-datos.git
cd proyecto-saas-calidad-datos
```

---

### 2. Backend

Abrir en Visual Studio y ejecutar:

```
F5
```

Verificar Swagger:

```
https://localhost:7093/swagger
```

---

### 3. Frontend

```bash
cd proyectosaasfrontend
npm install
npm start
```

Abrir en:

```
http://localhost:3000
```

---

## 🔌 Endpoints principales

### Analizar datos

```
GET /api/clientes/analizar
```

Devuelve:

* resumen
* errores
* ejemplos

---

### Sanitizar datos

```
GET /api/clientes/sanitizar
```

Devuelve:

* métricas de datos limpios
* score de calidad post-sanitización

---

## 📈 Ejemplo de resultado

```json
{
  "resumen": [
    {
      "totalRegistros": 150000,
      "scoreCalidad": 7
    }
  ]
}
```

---

## 💡 Caso de uso

Este sistema permite:

* Auditar bases de datos de clientes
* Detectar problemas de calidad
* Mejorar la confiabilidad de los datos
* Preparar datasets para marketing, ventas o analytics

---

## 🔥 Próximas mejoras

* Comparación antes vs después
* Exportación de datos sanitizados (Excel)
* Autenticación de usuarios
* Subida de archivos por UI
* Dashboard con gráficos

---

## 👨‍💻 Autor

Proyecto desarrollado como base para un SaaS de calidad de datos.

---
