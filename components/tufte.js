import styles from "../styles/layout.module.css"

import Head from "next/head"

function Tufte({ children }) {
  return (
    <>
      <Head>
        <link rel="preload" href="/fonts/Recursive_Mono_Csl_St_Extra_Bd.woff2" as="font" crossOrigin="" />
        <link rel="preload" href="/fonts/Recursive_Mono_Csl_St_Regular.woff2" as="font" crossOrigin="" />
      </Head>
      <div className={styles.tufte}>
        {children}
      </div>
    </>
  )
}

export default Tufte