import './App.css'

function App() {
  const highlights = [
    'Memorable and brandable name',
    'Short .com with strong trust factor',
    'Perfect for software, SaaS, or consulting',
  ]

  return (
    <main className="site-shell">
      <div className="ambient ambient-left" aria-hidden="true" />
      <div className="ambient ambient-right" aria-hidden="true" />

      <header className="topbar">
        <p className="brand">SOFTLLC.COM</p>
        <span className="topbar-note">Domain available now</span>
      </header>

      <section className="hero">
        <p className="kicker">Premium domain opportunity</p>
        <h1>softllc.com is for sale.</h1>
        <p className="hero-copy">
          Secure a clean, professional domain for your software brand. If you are building a product studio,
          consulting company, SaaS business, or AI venture, softllc.com gives you a credible and memorable digital home.
        </p>
        <div className="hero-actions">
          <a className="button button-primary" href="mailto:dan@softllc.com">
            Make an offer
          </a>
          <a className="button button-ghost" href="#details">
            View details
          </a>
        </div>
      </section>

      <section id="details" className="grid-section">
        <h2>Why this domain stands out</h2>
        <div className="card-grid">
          {highlights.map((item) => (
            <article className="card" key={item}>
              <h3>{item}</h3>
              <p>
                Strong naming signal, easy recall, and broad relevance across multiple business categories.
              </p>
            </article>
          ))}
        </div>
      </section>

      <section className="split-section">
        <article className="panel">
          <h2>Simple acquisition process</h2>
          <p>
            Send your offer by email and include your preferred timeline. All serious inquiries receive a prompt response.
            Transfer can be completed through a secure domain escrow process.
          </p>
        </article>
        <article className="panel panel-accent">
          <h2>Buyer notes</h2>
          <ul>
            <li>Fast response to qualified buyers</li>
            <li>Secure transfer with standard protections</li>
            <li>Flexible closing timeline</li>
          </ul>
        </article>
      </section>

      <section className="founder">
        <h2>Serious inquiries only</h2>
        <p>
          This is a direct sale opportunity for softllc.com. If this domain fits your business, reach out with your
          offer and intended use case.
        </p>
      </section>

      <section className="cta">
        <h2>Ready to purchase softllc.com?</h2>
        <p>
          Contact the owner today to start the transaction.
        </p>
        <div className="hero-actions">
          <a className="button button-primary" href="mailto:dan@softllc.com?subject=softllc.com%20domain%20offer">
            Email your offer
          </a>
          <a className="button button-ghost" href="mailto:dan@softllc.com?subject=softllc.com%20domain%20inquiry">
            Ask a question
          </a>
        </div>
      </section>
    </main>
  )
}

export default App
