import { useState, useEffect } from 'react';

const useMonitorRecaptchaResponse = () => {
  const [recaptchaFilled, setRecaptchaFilled] = useState(false);
  const query = '#g-recaptcha-response';

  useEffect(() => {
    function checkRecaptcha() {
      console.log("checkRecaptcha")
      const element = document.querySelector(query);
      const isFilled = !!(element && element.value);
      setRecaptchaFilled(isFilled);
    }

    const element = document.querySelector(query);
    const observer = new MutationObserver(checkRecaptcha);

    if (element) observer.observe(element, { attributes: true });

    return () => observer.disconnect();
  }, [query]);

  return recaptchaFilled;
};

export default useMonitorRecaptchaResponse;
