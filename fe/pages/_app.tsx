import '../styles/globals.css'
import type { AppProps } from 'next/app'
import Layout from '../components/Layout'
import { appWithTranslation } from 'next-i18next'
import { QueryClient, QueryClientProvider } from 'react-query'
import i18Config from '../next-i18next.config'
import Head from 'next/head'

const queryClient = new QueryClient()

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <QueryClientProvider client={queryClient}>
      <Head>
        <meta
          name="viewport"
          content="width=device-width; initial-scale=1; viewport-fit=cover"
        />
        <meta name="mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-capable" content="yes" />

        <meta
          name="apple-mobile-web-app-status-bar-style"
          content="white-translucent"
        />
        <link rel="manifest" href="/manifest.json" />
        <link
          rel="icon"
          type="image/png"
          href="/img/logo-icon/logo16.png"
          sizes="16x16"
        />
        <link
          rel="icon"
          type="image/png"
          href="/img/logo-icon/logo32.png"
          sizes="32x32"
        />
        <link
          rel="apple-touch-icon"
          href="/img/logo-icon/logo192apple.png"
        ></link>
      </Head>
      <Layout>
        <Component {...pageProps} />
      </Layout>
    </QueryClientProvider>
  )
}

export default appWithTranslation(MyApp, i18Config)
