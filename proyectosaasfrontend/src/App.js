import { useEffect, useState } from "react";

function App() {
  const [data, setData] = useState(null);
  const [sanitizado, setSanitizado] = useState(null);

  useEffect(() => {
    fetch("https://localhost:7093/api/clientes/analizar")
      .then(res => res.json())
      .then(data => setData(data))
      .catch(err => console.error(err));
  }, []);

  if (!data) return <p>Cargando...</p>;

  const resumen = data.resumen[0];
  const errores = data.errores[0];

  const ejecutarSanitizacion = () => {
    fetch("https://localhost:7093/api/clientes/sanitizar")
      .then(res => res.json())
      .then(data => {
        console.log("Sanitizado:", data);
        setSanitizado(data.resumen[0]);
      })
      .catch(err => console.error(err));
  };

  return (
    <div style={{ padding: "20px", fontFamily: "Arial" }}>
      <h1>Dashboard de Calidad de Datos</h1>

      {/* SCORE */}
      <div style={{ 
        background: "#222", 
        color: "#fff", 
        padding: "20px", 
        borderRadius: "10px",
        marginBottom: "20px"
      }}>
        <h2>Score de Calidad</h2>
        <h1>{resumen.scoreCalidad} / 100</h1>
      </div>

      <button 
        onClick={ejecutarSanitizacion}
        style={{
          padding: "10px 20px",
          background: "#28a745",
          color: "white",
          border: "none",
          borderRadius: "5px",
          cursor: "pointer",
          marginBottom: "20px"
        }}
      >
        Sanitizar Datos
      </button>

      {/* MÉTRICAS */}
      <div style={{ display: "flex", gap: "20px", flexWrap: "wrap" }}>
        
        <Card title="Registros Totales" value={resumen.totalRegistros} />
        <Card title="Perfectos" value={`${resumen.registrosPerfectos} (${resumen.pctPerfectos}%)`} />
        <Card title="Utilizables" value={`${resumen.registrosUtilizables} (${resumen.pctUtilizables}%)`} />
        <Card title="Con Problemas" value={`${resumen.registrosConProblemas} (${resumen.pctConProblemas}%)`} />

      </div>

      {sanitizado && (
        <div style={{ marginTop: "30px" }}>
          <h2>Resultado Sanitización</h2>

          <div style={{ display: "flex", gap: "20px", flexWrap: "wrap" }}>
            <Card title="Emails utilizables" value={`${sanitizado.emailsUtilizables} (${sanitizado.pctEmailsUtilizables}%)`} />
            <Card title="Teléfonos utilizables" value={`${sanitizado.telefonosUtilizables} (${sanitizado.pctTelefonosUtilizables}%)`} />
            <Card title="Registros utilizables" value={`${sanitizado.registrosUtilizables} (${sanitizado.pctUtilizables}%)`} />
            <Card title="Score" value={`${sanitizado.scoreCalidad}/100`} />
          </div>
        </div>
      )}

      {/* ERRORES */}
      <h2 style={{ marginTop: "30px" }}>Errores</h2>

      <div style={{ display: "flex", gap: "20px", flexWrap: "wrap" }}>
        <Card title="Emails inválidos" value={errores.emailsInvalidos} />
        <Card title="Emails duplicados" value={errores.emailsDuplicados} />
        <Card title="Teléfonos inválidos" value={errores.telefonosInvalidos} />
        <Card title="Fechas inválidas" value={errores.fechasInvalidas} />
      </div>

    </div>
  );
}

function Card({ title, value }) {
  return (
    <div style={{
      border: "1px solid #ccc",
      borderRadius: "10px",
      padding: "15px",
      minWidth: "200px",
      background: "#f9f9f9"
    }}>
      <h4>{title}</h4>
      <h2>{value}</h2>
    </div>
  );
}

export default App;