describe Api::WebhooksController, type: :controller do
  let!(:params) { 
    { message: {
       message_id: 23, 
       text: 'hello', 
       data: { 
         id: 1, 
         from: { 
           id: 2, 
           username: 'Test' 
          } 
        }.as_json, 
        id: 1, from: { id: 2, username: 'Text' }
      },
      data: { id: 33 }
     }
  }

  describe '#update' do
    subject { response }

    context 'when data is present' do
      before { post :update, params: params }

      it { is_expected.to have_http_status(200) }
    end

    context 'when data is absent' do
      let(:params) { { message: '' } } 

      before { post :update, params: params }

      it { is_expected.to have_http_status(422) }
    end
  end
end