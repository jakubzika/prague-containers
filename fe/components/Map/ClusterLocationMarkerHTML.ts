const ClusterLocationMarkerHTML = (count: number, countAbbr: string) => {
  const el = document.createElement('div')
  el.innerHTML = `
  <svg width="50" height="33" viewBox="0 0 50 33" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M17 0.35H32C38.4341 0.35 43.65 5.56589 43.65 12V32.0196H5.35V12C5.35 5.56589 10.5659 0.35 17 0.35Z" fill="#C4C4C4" stroke="black" stroke-width="0.7"/>
<path d="M6 8.35H43C46.1204 8.35 48.65 10.8796 48.65 14V21C48.65 24.1204 46.1204 26.65 43 26.65H0.35V14C0.35 10.8796 2.87959 8.35 6 8.35Z" fill="white" stroke="black" stroke-width="0.7"/>
<text fill="black" xml:space="preserve" style="white-space: pre" font-family="Poppins" font-size="14" letter-spacing="0em"><tspan x="5" y="24.4">${countAbbr}</tspan></text>
</svg>  
  `
  return el;
}

export default ClusterLocationMarkerHTML